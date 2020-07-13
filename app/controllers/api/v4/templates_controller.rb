class Api::V4::TemplatesController < Api::V4::ApiController
  load_and_authorize_resource :stable

  api! 'Lists tags in that stable'
  param :type, TagType.all.pluck(:title), 'Filter tags to type'
  example '[
    {
        "id": 12,
        "name": "Slå græs",
        "prefilled_title": "Græsset skal slåes",
        "tag_type": "todo",
        "note": "Husk at komme ud i hjørnerne",
        "horses": [],
        "tags": []
    },
    {
        "id": 13,
        "name": "Rengøring stald",
        "prefilled_title": "",
        "tag_type": "todo",
        "note": "",
        "horses": [],
        "tags": []
    },
    {
        "id": 14,
        "name": "Skift sko",
        "prefilled_title": "Skift sko",
        "tag_type": "todo",
        "note": "",
        "horses": [],
        "tags": [
            2
        ]
    }
]'
  def index
    templates = @stable.templates
    templates = templates.includes(:tag_type).where(tag_types: {title: params[:type]}) unless params[:type].nil?
    render_for_api :basic, json: templates
  end

  def find_templates
    templates = @stable.templates
    templates = templates.includes(:tag_type).where(tag_types: {title: params[:type]}) unless params[:type].nil?
    templates = Template.select_templates(templates, @stable, current_user, TagType.find_by(title: params[:type])) unless params[:type].nil?
    render_for_api :basic, json: templates
  end
end
