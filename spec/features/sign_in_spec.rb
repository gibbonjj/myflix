require 'spec_helper'

feature "user signs in" do
  scenario "with valid email and password" do
    john = Fabricate(:user)
    sign_in(john)
    page.should have_content john.full_name
  end
end
