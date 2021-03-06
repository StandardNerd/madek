def stable_part_of_meta_datum_departement dep_name
  dep_name.match(/^(.*)\(/).captures.first
end


Then /^I can see every meta\-data\-value somewhere on the page$/ do
  @meta_data_by_context.each do |meta_context_name,meta_data|
    meta_data.each do |md|
      value= md[:value]
      case md[:type]
      when 'meta_datum_departments'
        expect(page).to have_content stable_part_of_meta_datum_departement(value)
      else
        expect(page).to have_content value
      end
    end
  end
end


Given /^I change the value of each meta\-data field of each context$/  do

  @meta_data_by_context=HashWithIndifferentAccess.new

  all("ul.contexts li").each do |context|
    context.find("a").click()
    step 'I change the valule of each visible meta-data field'
    @meta_data_by_context[context[:'data-context-name']] = @meta_data
  end
end

When /^I change the value of each visible meta\-data field$/ do
  @meta_data= []
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    type = field_set[:'data-type']
    meta_key = field_set[:'data-meta-key']


    case type

    when 'meta_datum_string'
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: Faker::Lorem.words.join(" "),
        meta_key: meta_key,
        type: type)
      if field_set.all("textarea").size > 0
        field_set.find("textarea").set(@meta_data[i][:value])
      else
        field_set.find("input[type='text']").set(@meta_data[i][:value])
      end

    when 'meta_datum_people' 
      # remove all existing 
      field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
      @people ||= Person.all
      random_person =  @people[rand @people.size]
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: random_person.to_s,
        meta_key: meta_key,
        type: type)
      field_set.find("input.form-autocomplete-person").set(random_person.to_s)
      page.execute_script %Q{ $("input.form-autocomplete-person").trigger("change") }
      wait_until{  field_set.all("a",text: random_person.to_s).size > 0 }
      field_set.find("a",text: random_person.to_s).click

    when 'meta_datum_date' 
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: Time.at(rand Time.now.tv_nsec).iso8601,
        meta_key: meta_key,
        type: type)
        field_set.find("input", visible: true).set(@meta_data[i][:value])

    when 'meta_datum_keywords'

      field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
      @kws ||= MetaTerm.joins(:keywords).select("de_ch").uniq.map(&:de_ch).sort
      random_kw = @kws[rand @kws.size]
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: random_kw,
        meta_key: meta_key,
        type: type)
      field_set.find("input", visible: true).set(random_kw)
      page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
      wait_until{  field_set.all("a",text: random_kw).size > 0 }
      field_set.find("a",text: random_kw).click


    when 'meta_datum_meta_terms'
      if field_set['data-is-extensible-list']
        field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
        field_set.find("input",visible: true).click
        page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
        wait_until{ field_set.all("ul.ui-autocomplete li a",visible: true).size >0 }
        targets = field_set.all("ul.ui-autocomplete li a",visible: true)
        targets[rand targets.size].click
        wait_until{ field_set.all("ul.multi-select-holder li.meta-term").size > 0}
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: field_set.first("ul.multi-select-holder li.meta-term").text, 
          type: type,
          meta_key: meta_key) 
      else
        checkboxes = field_set.all("input",type: 'checkbox', visible: true)
        checkboxes.each{|c| c.set false}
        checkboxes[rand checkboxes.size].click
        @meta_data[i] = HashWithIndifferentAccess.new(
          value: field_set.all("input", type: 'checkbox', visible: true,checked: true).first.find(:xpath,".//..").text,
          meta_key: meta_key,
          type: type) 
      end

    when 'meta_datum_departments' 
      field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
      field_set.find("input",visible: true).click
      directly_chooseable= field_set.all("ul.ui-autocomplete li:not(.has-navigator) a",visible: true)
      directly_chooseable[rand directly_chooseable.size].click
      @meta_data[i] = HashWithIndifferentAccess.new(
        value: field_set.first("ul.multi-select-holder li.meta-term").text, 
        type: type,
        meta_key: meta_key) 
    else
      rais "Implement this case" 
    end

  end
end

Then /^each meta\-data value in each context should be equal to the one set previously$/ do
  all("ul.contexts li").each do |context|
    context.find("a").click()
    @meta_data ||= @meta_data_by_context[context[:'data-context-name']]
    step 'each meta-data value should be equal to the one set previously'
  end
end

Then /^each meta\-data value should be equal to the one set previously$/ do
  all("form fieldset",visible: true).each_with_index do |field_set,i|
    type = field_set[:'data-type']
    meta_key = field_set[:'data-meta-key']

    case type
    when 'meta_datum_string'
      if field_set.all("textarea").size > 0
        expect(field_set.find("textarea").value).to eq @meta_data[i][:value]
      else
        expect(field_set.find("input[type='text']").value).to eq @meta_data[i][:value]
      end
    when 'meta_datum_people' 
      expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
    when 'meta_datum_date' 
      expect(field_set.find("input", visible: true).value).to eq @meta_data[i][:value]
    when 'meta_datum_keywords'
      #expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
      expect(field_set.all("ul.multi-select-holder li",text: @meta_data[i][:value]).size ).to eq 1
    when 'meta_datum_meta_terms'
      if field_set['data-is-extensible-list']
        expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
      else
        expect(field_set.all("input", type: 'checkbox', visible: true,checked: true).first.find(:xpath,".//..").text).to eq @meta_data[i][:value]
      end
    when 'meta_datum_departments' 
      expect( stable_part_of_meta_datum_departement(field_set.first("ul.multi-select-holder li.meta-term").text)).to \
        eq stable_part_of_meta_datum_departement(@meta_data[i][:value])
    else
      raise "Implement this case"
    end
  end
end


Then /^I am on the page of my first media_entry$/ do
  @media_entry = @me.media_entries.reorder(:id).first
  expect(current_path).to eq  media_entry_path(@media_entry)
end

When /^I delete all existing authors$/ do
  all("fieldset[data-meta-key='author'] ul.multi-select-holder li a",visible:true).each{|e| e.click}
end

When /^I click on the icon of the author fieldset$/ do
  find("fieldset[data-meta-key='author'] a.form-widget-toggle").click
end


When /^I wait for multi\-select\-tag with the text "(.*?)"$/ do |text|
  wait_until{all("li.multi-select-tag",text: text).size > 0}
end

Then /^the textarea within the fieldset "(.*?)" is empty$/ do |meta_key|
  expect(find("fieldset[data-meta-key='#{meta_key}'] textarea").value.strip).to eq ""
end

Then /^the textarea within the fieldset "(.*?)" is not empty$/ do |meta_key|
  expect(find("fieldset[data-meta-key='#{meta_key}'] textarea").value.strip).not_to eq ""
end
