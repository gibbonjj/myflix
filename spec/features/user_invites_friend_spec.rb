require 'spec_helper'

feature 'User invites friend' do
  scenario 'User successfully invites friend and invitaion is accepted' do
    bob = Fabricate(:user)
    sign_in(bob)

    invite_a_friend
    friend_accepts_invite
    friend_signs_in
    friend_should_follow(bob)
    inviter_should_follow_friend(bob)

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in "Friend's name", with: "john"
    fill_in "Friend's email address", with: "john@yahoo.com"
    fill_in "Send a message", with: "Join us"
    click_button "Send Invitation"
    sign_out
  end

  def friend_accepts_invite
    open_email "john@yahoo.com"
    current_email.click_link "Accept this invitation"
    fill_in "Password", with: "password"
    fill_in "Full Name", with: "john"
    click_button "Sign Up"
  end

  def friend_signs_in
    fill_in "Email Address", with: "john@yahoo.com"
    fill_in "Password", with: "password"
    click_button "Sign in"
  end

  def friend_should_follow(user)
    click_link "People"
    expect(page).to have_content user.full_name
    sign_out
  end

  def inviter_should_follow_friend(inviter)
    sign_in(inviter)
    click_link "People"
    expect(page).to have_content "john"
  end
end
