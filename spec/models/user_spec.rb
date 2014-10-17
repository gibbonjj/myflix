require 'spec_helper'

describe User do
  it { should have_many(:queue_items).order(:position) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:full_name) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:reviews).order("created_at DESC") }

  it_behaves_like "tokenable" do
    let(:object) { Fabricate(:user) }
  end

  describe "#queued_video?" do
    it "returns true if the video has been queued" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      Fabricate(:queue_item, user: user, video: video)
      user.queued_video?(video).should be_truthy
    end
    it "returns false if the vidoe has not been queued" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      user.queued_video?(video).should be_falsey
    end
  end

  describe "#follows?" do
    it "returns true if the user has a following relationship with another user" do
      john = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, follower: john, leader: bob)
      expect(john.follows?(bob)).to be_truthy
    end
    it "returns false if the user does not have a following relationship with another user" do
      john = Fabricate(:user)
      bob = Fabricate(:user)
      expect(john.follows?(bob)).to be_falsey
    end
  end

  describe "#follow" do
    it "follows another user" do
      john = Fabricate(:user)
      bob = Fabricate(:user)
      john.follow(bob)
      expect(john.follows?(bob)).to be_truthy
    end
    it "does not follow oneself" do
      john = Fabricate(:user)
      john.follow(john)
      expect(john.follows?(john)).to be_falsey
    end
  end
end
