Then /^the search results should (not )?contain "([^"]*)"$/ do |shouldnt_they, title|
  #find("#media_entry_results")
  #find("#detail_specification").text.include?(title).should == (shouldnt_they.blank? ? true : false)
  wait_until { find("#results .item_box") }
  find("#results").text.include?(title).should == (shouldnt_they.blank? ? true : false)

  #group.users.include?(user).should == (shouldnt_they.blank? ? true : false)
end
