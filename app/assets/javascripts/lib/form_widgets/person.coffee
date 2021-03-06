###

FormWidget for People

###

FormWidgets = {} unless FormWidgets?
class FormWidgets.Person

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".form-person-widget .add-person, .form-person-widget .add-group", (e) => 
      @addPerson $(e.currentTarget).closest(".tab-pane").find("input"), $(e.currentTarget).closest(".form-widget")
    @el.on "keydown", ".form-person-widget .add-person input, .form-person-widget .add-group input", (e) => 
      if e.keyCode == 13
        @addPerson $(e.currentTarget).closest(".tab-pane").find("input"), $(e.currentTarget).closest(".form-widget")

  addPerson: (inputs, widget)->
    person = new App.Person
    for input in inputs
      person[input.name] = $(input).val() if $(input).val().length
    if person.validate()
      return true if widget.closest(".multi-select-holder").find(".multi-select-tag[data-string='#{person.toString()}']").length
      person.create (data)=>
        index = widget.closest(".ui-form-group").data "index"
        person = new App.Person data
        person.index = index
        inputHolder = widget.closest(".multi-select-holder").find(".multi-select-input-holder")
        inputHolder.before App.render "media_resources/edit/multi-select/person", person
        inputHolder.find("input:visible").trigger "change"
      inputs.val ""
    else
      # error

window.App.FormWidgets = {} unless window.App.FormWidgets
window.App.FormWidgets.Person = FormWidgets.Person
