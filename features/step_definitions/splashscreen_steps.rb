Then /^I should see an image rotation of the splashscreen set$/ do
  wait_until { find(".nivo-caption") }
  MediaSet.find(AppSettings.splashscreen_slideshow_set_id).child_media_resources.media_entries.map(&:title).should include find(".nivo-caption strong").text
end