require 'rails_helper'

RSpec.describe "depictions/new", type: :view do
  before(:each) do
    assign(:depiction, Depiction.new(
      :depiction_object => "",
      :image => nil,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders new depiction form" do
    render

    assert_select "form[action=?][method=?]", depictions_path, "post" do

      assert_select "input#depiction_depiction_object[name=?]", "depiction[depiction_object]"

      assert_select "input#depiction_image_id[name=?]", "depiction[image_id]"

      assert_select "input#depiction_created_by_id[name=?]", "depiction[created_by_id]"

      assert_select "input#depiction_updated_by_id[name=?]", "depiction[updated_by_id]"

      assert_select "input#depiction_project_id[name=?]", "depiction[project_id]"
    end
  end
end