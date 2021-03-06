Feature: importing an image

  @chrome
  Scenario: Importing images and setting some metadata
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    And I attach the file "images/date_should_be_1990.jpg"
    And I attach the file "images/date_should_be_2011-05-30.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "3" new media_entries
    And there is a entry with the title "Berlin Wall" in the new media_entries

  @chrome
  Scenario: Highlighting and enforcing required meta fields
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    When I click on the link "Weiter"
    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    Then I can see that the fieldset with "title" as meta-key is required
    Then I can see that the fieldset with "copyright notice" as meta-key is required
    When I click on the link "Weiter…" 

    Then I am on the "/import/meta_data" page
    And I see an error alert
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 
    And I wait until I am on the "/import/organize" page


  @chrome
  Scenario: Setting permissions during the import
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I set the input with the name "user" to "Paula, Petra"
    And I click on "Paula, Petra" inside the autocomplete list
    Then the "view" permission for "Paula, Petra" is checked
    When I click on the "download" permission for "Paula, Petra"
    Then the "download" permission for "Paula, Petra" is checked
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    And there is a entry with the title "Berlin Wall" in the new media_entries
    And Petra has "view" user-permission on the new media_entry with the tile "Berlin Wall"
    And Petra has "download" user-permission on the new media_entry with the tile "Berlin Wall"


  @chrome 
  Scenario: Adding the imports to a new set 
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    And I attach the file "images/date_should_be_1990.jpg"
    And I attach the file "images/date_should_be_2011-05-30.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the link "Einträge zum einem Set hinzufügen"
    And I wait for the dialog to appear
    And I set the input with the name "search_or_create_set" to "Import Test Set"
    And I click on the button "Neues Set erstellen"
    And I click on the button "Speicher"
    And I wait for the dialog to disappear
    And I click on the button "Import abschliessen"

    Then there are "3" new media_entries


  @chrome
  Scenario: Canceling import preservers import files

    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    And I click on the link "Weiter…" 
    And I wait until I am on the "/import/permissions" page
    When I click on the link "Abbrechen"
    Then I am on the "/my" page
    When I click on the link "Medien importieren"
    Then there is "berlin_wall_01.jpg" in my imports


  @chrome 
  Scenario: Deleting files during the import 
  
    Given I am signed-in as "Normin"
    And There is no media-entry with a filename matching "berlin"
    And There is no incomplete media-entry with a filename matching "berlin"

    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    And I attach the file "images/berlin_wall_02.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I go to the import page
    And I delete the import "berlin_wall_01.jpg"
    And I confirm the browser dialog
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall 01" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "1" new media_entries
    And There is exactly one media-entry with a filename matching "berlin"
    And There is no media-entry incomplete with a filename matching "berlin"


  @chrome
  Scenario: Importing a video creates a Zencoder.job and submits it
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "zencoder_test.mov"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Zencoder Movie" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "1" new media_entries
    And there is a entry with the title "Zencoder Movie" in the new media_entries
    And there are "1" new zencoder_jobs
    And The most recent zencoder_job has the state "submitted"

  @chrome @clean
  Scenario: Importing a file with 0 bytes
    Given I am signed-in as "Normin"
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "files/empty_file.mp3"
    Then I see an error alert











