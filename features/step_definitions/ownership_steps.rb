# coding: UTF-8

When /^I change the owner to "([^"]*)"$/ do |new_owner|
  @media_set = MediaSet.accessible_by_user(@current_user, :edit).first
  visit media_set_path @media_set
  step 'I open the permission lightbox'
  wait_until { all(".users .line.add .button").size > 0 }
  find(".users .line.add .button").click
  wait_until { find(".users .line.add input") }.set(new_owner)
  wait_until { find(".ui-autocomplete li a") }.click
  find(".users .line", :text => new_owner).find(".owner input").click
  step 'I save the permissions'
end


Then /^I am no longer the owner$/ do
  @media_set.reload.user.should_not == @current_user
end

Then /^the resource is owned by "([^"]*)"$/ do |owner|
  @media_set.reload.user.should == (User.find_by_login owner.downcase)
end


Given /^a resource owned by me$/ do
  @media_set = MediaSet.accessible_by_user(@current_user, :edit).first
end

Then /^I can use some interface to change the resource's owner to "([^"]*)"$/ do |new_owner|
  visit media_set_path(@media_set)
  step 'I open the permission lightbox'
  find(".users .line.add .button").click
  find(".users .line.add input").set(new_owner)
  wait_until { find(".ui-autocomplete li a") }.click
  find(".users .line .owner input").should_not be_nil
end


When /^I vist that resource's page$/ do
  visit media_resource_path(@media_set)
end

When /^I see a list of resources$/ do
  visit media_resources_path
  wait_until {all(".item_box").size > 0}
end

Then /^I can see if a resource is only visible for me$/ do
  while all(".item_box .icon_status_perm_private").size == 0 do scroll_to_next_page end
  find(".item_box .icon_status_perm_private")
end

Then /^I can see if a resource is visible for multiple other users$/ do
  while all(".item_box .icon_status_perm_shared").size == 0 do scroll_to_next_page end
  find(".item_box .icon_status_perm_shared")
end

Then /^I can see if a resource is visible for the public$/ do
  while all(".item_box .icon_status_perm_public").size == 0 do scroll_to_next_page end
  find(".item_box .icon_status_perm_public")
end

Then /^I see a list of content owned by me$/ do
  # TODO real test using presets (in rspec ??)
  find(".content_body .page_title_left", :text => "Meine Inhalte")
end

Then /^I see a list of content that can be managed by me$/ do
  # FIXME the current implementation is wrong!
  # TODO real test using presets (in rspec ??)
  find(".content_body .page_title_left", :text => "Mir anvertraute Inhalte")
end

Then /^I see a list of other people's content that is visible to me$/ do
  # TODO real test using presets (in rspec ??)
  find(".content_body .page_title_left", :text => "Öffentliche Inhalte")
end

When /^I open the set called "([^"]*)"$/ do |set_title|
  visit media_set_path(@current_user.media_sets.find_by_title(set_title))

end

When /^I want to change the owner$/ do
  step 'I open the permission lightbox'
end

When /^I open the permission lightbox$/ do
  step 'I hover the context actions menu'
  wait_until { find(".open_permission_lightbox") }
  page.execute_script %Q{ $(".open_permission_lightbox").parents("*").show(); }
  find(".open_permission_lightbox").click
  wait_until { find(".permission_lightbox .line") }
end

Then /^I can choose a user as owner$/ do
  page.has_css?(".permission_view .users .line .owner input").should == true
  all(".groups .line .owner input").size >= 0
end

Then /^I can not choose any groups as owner$/ do
  all(".groups .line .owner input").size == 0
  all(".public .line .owner input").size == 0
end

When /^I open one of my resources$/ do
  visit root_path
  wait_until { find(".results .item_box .thumb_box") }.click
end

When /^I open a media ([^"]*) owned by someone else$/ do |arg1|
  visit root_path
  what = case arg1
    when "resource"
      nil
    when "entry"
      " .thumb_box"
    when "set"
      " .thumb_box_set"
  end
  wait_until { find(".results.others .item_box#{what}") }.click
end

Then /^I cannot change the owner$/ do
  step 'I open the permission lightbox'
  all(".permission_lightbox .owner").each do |owner_field|
    owner_field.find("input[disabled=disabled]") if owner_field.all("input").size>0
  end
end

When /^"([^"]*)" changes the resource's permissions for "([^"]*)" as follows:$/ do |owner, new_owner, table|
  visit media_resource_path(@resource)
  step 'I open the permission lightbox'
  wait_until { find(".users .line.add .button") }.click
  wait_until { find(".users .line.add input") }.set(new_owner)
  wait_until { find(".ui-autocomplete li a") }.click

  table.hashes.each do |perm| 
    if (perm["value"] == "false" and find(%Q@.users .line input##{perm["permission"]}@).selected?) \
      or (perm["value"] == "true" and (not find(%Q@.users .line input##{perm["permission"]}@).selected?))
        find(%Q@.users .line input##{perm["permission"]}@).click
    end
  end
  
  step 'I save the permissions'
end

Then /^the resource has the following permissions for "([^"]*)":$/ do |user_login, table|
  user = User.where("login = ?", user_login.downcase).first
  userpermission = Userpermission.where("user_id = ?",user.id).where("media_resource_id = ?",@resource.id).first
  table.hashes.each do |perm| 
    userpermission.send(perm["permission"]).to_s.should == perm["value"]
  end
end

Then /^I should have all permissions$/ do
  all(".me .permission").each do |permission|
    permission.find("input[checked=checked]")
  end
end

When /^I create a resource$/ do
  step 'I upload a file'
  visit "/import/permissions"
end

Then /^I am the owner of that resource$/ do
  find(".me .line .owner input").checked?
end

Then /^"([^"]*)" is still the original media entry's owner$/ do |user_login|
  user = User.find_by_login user_login.downcase
  @resource.user.should == user
end

Then /^I see who is the owner$/ do
  page.should have_content("Eigentümer/in")
end

Given /^I am a user that has ownership for a resource$/ do
  @user = User.select{|x| x.media_entries.count > 0}.first
  @resource = @user.media_entries.first
end

When /^I am figured as owner$/ do
  @resource.meta_data.get_value_for("owner").should == @user.to_s
end
