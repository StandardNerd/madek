# -*- encoding : utf-8 -*-
module MetaContextsHelper

  def display_context_abstract_slider(abstract_slider_hash)
    total = abstract_slider_hash[:total]
    url = abstract_meta_context_path(abstract_slider_hash[:context_id])
    
    capture_haml do
      haml_tag :p, :style => "padding: 1.8em;" do
        haml_tag :span, :id => "amount", :style => "color: #444444; font-weight: bold; position: absolute;"
      end
      haml_tag :div, :id =>"slider", :style => "border: 1px solid #DDDDDD;"
      
      script = javascript_tag do
        begin
        <<-HERECODE
          $(document).ready(function () {
            var total = #{total}; 
            function update_amount(ui){
              var l = ui.find("a").css('left');
              var v = ui.slider( "value" ) + " von " + total;
              $("#amount").html(v).css('left', l);
            }
            $("#slider").slider({
              value: #{total * 30 / 100},
              min: 1,
              max: total,
              step: 1,
              create: function( event, ui ) { update_amount($(this)); },
              slide: function( event, ui ) { update_amount($(this)); },
              change: function( event, ui ) {
                update_amount($(this));
                $.ajax({
                  url: "#{url}",
                  data: {value: ui.value},
                  complete: function(response){
                    $("#slider").nextAll(".meta_data:first").replaceWith(response.responseText);
                    browsing_document_ready();
                  }
                });
              }
            });
          });
        HERECODE
        end.html_safe
      end
      haml_concat script

    end
  end

  def display_context_abstract(abstract_hash)
    capture_haml do
      haml_tag :div, :class => "meta_data" do
        if abstract_hash.blank?
          haml_concat _("Es sind nicht genügend Werte für einen Set-Auszug vorhanden.")
        else
          abstract_hash.collect do |meta_datum|
            haml_tag :h4, meta_datum[:definition_label]
            haml_tag :p do
              meta_datum[:meta_terms].each do |meta_term|
                haml_concat link_to(meta_term[:label], media_resources_path(:meta_data => {meta_datum[:meta_key_label] => {:ids => [meta_term[:id]]}}), :"data-meta_term_id" => meta_term[:id])
              end
            end
          end
        end
      end
    end
  end

  def display_contexts_vocabulary(vocabulary_json)
    vocabulary_json = [vocabulary_json] unless vocabulary_json.is_a? Array
    
    capture_haml do
      haml_tag :br
      haml_tag :label, :style => "cursor: pointer;" do
        haml_tag :input, :type => "checkbox", :id => "terms_toggler", :checked => "false"
        haml_tag :strong, "Die bereits vergeben Werte hervorheben", :style => "position:relative;top:1px;left:2px;font-size:0.9em;letter-spacing:0;"
      end
      haml_tag :br
      haml_tag :br

      vocabulary_json.each do |context|
        haml_tag :h3, context[:label] if context[:label]
        haml_tag :p, context[:description] if context[:description]
        context[:meta_keys].each do |meta_key|
          haml_tag :h4, meta_key[:label]
          haml_tag :div, :class => "columns_3" do
            meta_key[:meta_terms].each do |meta_term|
              haml_tag :p, meta_term[:label], :"data-meta_term_id" => meta_term[:id], :"data-used" => meta_term[:is_used]
            end
          end
        end
      end

      script = javascript_tag do
        begin
        <<-HERECODE
          $(document).ready(function () {
            var unused_terms = $("p[data-meta_term_id][data-used='0']");
            var terms_toggler = $("#terms_toggler");
            $(terms_toggler).removeAttr("checked");
            terms_toggler.change(function(){
              if ($(this).attr("checked") == "checked") {
                unused_terms.addClass("disabled");
              } else {
                unused_terms.removeClass("disabled");
              }
            });
          });
        HERECODE
        end.html_safe
      end
      haml_concat script
    end
  end
  
end
