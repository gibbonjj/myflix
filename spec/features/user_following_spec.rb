require 'spec_helper'

feature 'User following' do
  scenario "user follow and unfollows someone" do

    john = Fabricate(:user)
    category = Fabricate(:category, name: "horror")
    video = Fabricate(:video, categories: [category])
    Fabricate(:review, user: john, video: video)

    sign_in
    click_on_video_on_home_page(video)

    click_link john.full_name
    click_link "Follow"
    expect(page).to have_content(john.full_name)

    unfollow(john)
    expect(page).not_to have_content(john.full_name)

  end

  def unfollow(user)
    find("a[data-method='delete']").click
  end
end
