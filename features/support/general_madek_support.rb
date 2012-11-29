# coding: UTF-8

Before do
  # This is run before EVERY scenario. It's necessary to prevent
  # tests trying to fetch media entries from cache that don't exist
  # anymore on the database.
  Rails.cache.clear
end



# Need to escape these special characters because they might appear in the
# labels we use in the metadata editor form.
def filter_string_for_regex(string)
  return string.gsub('/', '\\/')\
               .gsub("'","\'")\
               .gsub('(','\\(')\
               .gsub(')','\\)')
end

# Need to escape these special characters because they might appear in the values
# we want to pick from an autocomplete field
def filter_string_for_javascript(string)
  return string.gsub("'","\'")\
               .gsub("(","\(")\
               .gsub(")","\)")
end


def make_hidden_items_visible
  page.execute_script '$(":hidden").show();'
  sleep 0.5
end

def make_entries_controls_visible
  wait_until { find(".item_box") }
  page.execute_script '$(".item_box *:hidden").show();'
  sleep 1.5
end

def click_on_arrow_next_to(word)
  find(".head_menu", :text => "#{word}").find("img.arrow").click
end

def create_group(groupname)
  Group.find_or_create_by_name(:name => groupname)
end

def wait_for_css_element(element)
  wait_until {
    page.has_css?(element, :visible => true)
  }
end

def set_term_checkbox(node, text)
  cb = node.find("ul li ul li", :text => text).find("input")
  cb.click unless cb[:checked] == "true" # a string, not a bool!
end

def select_from_multiselect_widget(node, text)
  node.find(".search_toggler").click
  pick_from_autocomplete(text)
end


def fill_in_for_media_entry_number(n, values)

  # More human-compatible, we fill_in...(1) to fill in the field
  # at index position 0
  media_entry_num = n - 1

  values.each do |k,v|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    all("ul", :text => /#{k}/)[media_entry_num].all("input").each do |ele|
      fill_in ele[:id], :with => v if ele[:id] =~ /_value$/
    end
  end

end

def fill_in_for_batch_editor(values)

  values.each do |k,v|
    # Fills in the "_value" field it finds in the UL that contains
    # the "key" text. e.g. "Titel*" or "Copyright"
    all("ul", :text => /#{k}/).first.all("textarea").each do |ele|
      fill_in ele[:id], :with => v if !ele[:id].match(/attributes_\d+_value$/).nil?
    end
  end

end


def click_media_entry_titled(title)
  entry = find_media_resource_titled(title)
  wait_until { entry.find("a") }
  entry.find("a img").click
  sleep 1.0
end

def click_media_set_titled(title)
  entry = find_media_resource_titled(title, MediaSet)
  wait_until { entry.find("a") }
  entry.find("a").click
  sleep 1.0
end

def oldschool_click_media_entry_titled(title)
  all("ul.items li").each do |entry|
    if entry.text =~ /#{title}/
      entry.find("a").click
    end
  end
end


# Sets the checkbox of the media entry with the given title to true.
def check_media_entry_titled(title)
  wait_until { find(".thumb_box") }
  # Crutch so we can check the otherwise invisible checkboxes (they only appear on hover,
  # which Capybara can't do)
  #make_hidden_items_visible
  make_entries_controls_visible
  entry = find_media_resource_titled(title)
  #cb_icon = entry.find(:css, ".check_box").find("img")
  cb_icon = entry.find(:css, "div.check_box")
  #debugger; puts "lala"
  cb_icon.click if (cb_icon.find(:xpath, "../../..")[:class] =~ /.*selected.*/).nil?
  # Old way, when it was a PNG
  #cb_icon.click if (cb_icon[:src] =~ /_on.png$/).nil? # Only click if it's not yet checked
end

# Attempts to find a media entry based on its title by looking for
# the .item_box that contains the title. Returns the whole .item_box element
# if successful, nil otherwise.
def find_media_resource_titled(title, type = MediaResource)
  page.execute_script("$(document).scrollTop(0)")
  wait_until { find(".item_box") }
  
  results = type.accessible_by_user(@current_user).find_by_title(title)
  results = Array(results) unless results.is_a? Array # because of the different behaviour of MediaSet and MediaEntry .find_by_title -.-

  find_media_resource_by_id results.first
end

def find_media_resource_by_id(id, type = MediaResource)
  page.execute_script("$(document).scrollTop(0)")
  wait_until { find(".item_box") }
  
  find_media_resource_element type.accessible_by_user(@current_user).find id
end

# find the interface element of a media resource on the current screen
def find_media_resource_element(mr)
  while (all(".item_box[data-id='#{mr.id}']").empty?) 
    scroll_to_next_page
  end 
  element = find(".item_box[data-id='#{mr.id}']")
  puts "Interface element was not found for that media resource" unless element
  return element
end

# switch context on the meta data edit page
def switch_to_next_meta_data_context
  find(".ui-state-active").find(:xpath, "following-sibling::li").find("a").click
end

# Options are:
# "pseudonym field": Use the "pseudonym" field instea of first or last name
# "group tab". Switch to the group tab to enter group information
def fill_in_person_widget(list_element, value, options = "")
  if options == "in-field entry box"
    id_prefix = list_element["data-meta_key"]
    field = list_element.find("##{id_prefix}_autocomplete_search")
    fill_in field[:id], :with => value
    press_enter_in(field[:id])
    sleep 3.0
  elsif options == "pseudonym field"
    list_element.find(".dialog_link").click
    fill_in "Pseudonym", :with => value
    click_link_or_button("Personendaten einfügen")
    sleep 3.0
  elsif options == "group tab"
    list_element.find(".dialog_link").click
    click_link "Gruppe"
    sleep 2
    list_element.all("form").each do |form|
      if form[:id] =~ /^new_group/
        group_form_id = form[:id]
         within("##{group_form_id}") do
          fill_in "Name", :with => value
        end
      end
    end
    click_link_or_button("Gruppendaten einfügen")
    sleep 3.0
  else
    lastname, firstname = value, value
    lastname, firstname = value.split(",") if value.include?(",")
    list_element.find(:css, ".dialog_link").click
    sleep 3.0
    fill_in "Nachname", :with => lastname
    fill_in "Vorname", :with => firstname
    click_link_or_button("Personendaten einfügen")
    sleep 3.0
  end
end


def fill_in_keyword_widget(list_element, value, options = "")
  if options == "pick from my keywords tab"
    list_element.find(".dialog_link").click
    list_element.find("li", :title => value).click
  elsif options == "pick from popular keywords tab"
    list_element.find(".dialog_link").click
    click_link "Beliebteste"
    list_element.find("li", :title => value).click
  elsif options == "pick from latest keywords tab"
    list_element.find(".dialog_link").click
    click_link "Neueste"
    list_element.find("li", :title => value).click
  else
    field = list_element.find("#keywords_autocomplete_search")
    fill_in field[:id], :with => value
    press_enter_in(field[:id])
  end
end




def find_permission_checkbox(type, to_or_from)

  # Currently we find this numerically by index position.
  # To do a better job at this, instead go and find the
  # input type=checkbox which has ?key=edit in its path attribute:
  # <input checked="" path="/media_entries/1/permissions/3?key=view" type="checkbox">

  # The HTML in the "everybody" part is different than in the normal table because it splits the checkboxes and
  # text lines with a <br>, therefore our index positions must compensate for that
  # positions: 0 = view for logged in
  #            1 = view for public
  #            2 = edit for logged in
  #            3 = edit for public
  #            4 = download hi-res for logged in
  #            5 = download hi-res for public

  if type == "view"
    if to_or_from.class == String
      text = /#{to_or_from}/
    elsif to_or_from == :everybody
      text = "Öffentlich"    
    end
    index = 1
  elsif type == "edit"
    if to_or_from.class == String
      text = /#{to_or_from}/
    elsif to_or_from == :everbody
      text = "Öffentlich"
    end
    index = 3
  elsif type == "download_hires"
    if to_or_from.class == String
      text = /#{to_or_from}/
    elsif to_or_from == :everbody
      text = "Öffentlich"
    end
    index = 5
  end
  cb = find(:css, "table.permissions").find("tr", :text => text).all("input")[index]
end


# DANGER: This is now (March 15, 2011) broken due to the way
# Capybara handles fill_in. I believe it used to trigger the keyUp event
# that is necessary for the autocomplete to kick in, but it no longer does
# so, breaking many of our tests. Needs more investigation.
def type_into_autocomplete(type, text)
  if type == :user
    wait_for_css_element(".users .add.line .button")
    find(".users .add.line .button").click
    find(".users .add.line input").set text
  elsif type == :group
    wait_for_css_element(".groups .add.line .button")
    find(".groups .add.line .button").click
    find(".groups .add.line input").set text
  elsif type == :add_member_to_group
    wait_for_css_element("#edit_group .add input")
    find("#edit_group .add input").set text
  else
    puts "Unknown autocomplete type '#{type}', please add this type to the method type_into_autocomplete()"
  end
    sleep(1.5)
end

# Picks the given text string from an autocomplete text input box
# that is stuck in an UL: ul.ui-autocomplete
def pick_from_autocomplete(text)
  wait_for_css_element("li.ui-menu-item")
  all("ul.ui-autocomplete").each do |ul|
    ul.all("li.ui-menu-item a").each do |item|
      if !item.text.match(/#{filter_string_for_regex(text)}/).nil?
        page.execute_script %Q{ $('.ui-menu-item a:contains("#{item.text}")').trigger("mouseenter").click(); }
      end
    end
  end
end


def press_enter_in(field_id)
enter_script = <<HERE
var e = jQuery.Event("keypress");
e.keyCode = $.ui.keyCode.ENTER;
e.which = $.ui.keyCode.ENTER;
$("##{field_id}").trigger(e);
HERE
  page.execute_script(enter_script)
end

def mock_media_entry(user, title, copyright_notice = "copyright notice")
  media_entry = FactoryGirl.create :media_entry, :user => user
  params = {:meta_data_attributes => {"0" => {:meta_key_label => "title", :value => title},
                                      "1" => {:meta_key_label => "copyright notice", :value => copyright_notice} }}
  media_entry.update_attributes(params)
  media_entry.reload.title.should == title
end

# Uploads a picture with a given title and a fixed copyright string.
# It's always the same picture, no way to change the image file yet.
def upload_some_picture(title = "Untitled")
    mock_media_entry(@current_user, title, "some dude")

    visit "/"
    page.should have_content(title)
end

# Creates a new set
def create_set(set_title = "Untitled Set")
  visit media_resources_path(:user_id => @current_user, :type => "media_sets")
  step 'I hover the context actions menu'
  find(".open_create_set_dialog").click
  find("input.title").set set_title
  click_link_or_button "Erstellen"
end

# Adds a media entry to a set. Only works if the media entry
# has a title, so that it shows up under /media_resources. The set
# also needs a title.
def add_to_set(set_title = "Untitled Set", picture_title = "Untitled", owner = "No one")
  visit "/media_resources"
  click_media_entry_titled(picture_title)
  step 'I hover the context actions menu'
  find(".has-set-widget").click
  wait_for_css_element(".widget .list")
  find("input##{set_title.gsub(/\s/, "_")}").click
  find(".widget .submit").click
  wait_until { all(".widget").size == 0 }
end

def scroll_to_next_page
  wait_until { all(".page[data-page]").size > 0 }
  page = find(".page[data-page]")[:"data-page"]
  
  wait_until {find(".page .pagination", :text => /Seite #{page}\svon/)}
  find(".page .pagination", :text => /Seite #{page}\svon/).click
  wait_until {all(".page[data-page='#{page}']").empty?}
  wait_until {
    all(".page[data-page='#{page}']").size == 0 and
    find(".page .pagination", :text => /Seite #{page}\svon/).find(:xpath, "./..") and
    find(".page .pagination", :text => /Seite #{page}\svon/).find(:xpath, "./..").all(".item_box img").size > 0
  }
end

# after filter panel has been updated, fetch fresh the selected term
def selected_term
  find(".key[data-key_name='#{@key_name}'] .term.selected")
end

def deselect_term(value)
  selected_checkbox = find(".term.selected input[value='#{value}']")
  selected_checkbox.find(:xpath, "./../../../..").find("h3").click
  selected_checkbox.find(:xpath, "./../../..").find("h3").click
  selected_checkbox.find(:xpath, "./..").click
end
