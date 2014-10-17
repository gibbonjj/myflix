require 'spec_helper'

describe RelationshipsController do
  describe "GET index" do
    it "sets @relationships to the current user's following relationships" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: john, leader: bob)
      get :index
      expect(assigns(:relationships)).to eq([relationship])
    end
    it_behaves_like "requires sign in" do
      let(:action) { get :index }
    end
  end

  describe "POST create" do
    it_behaves_like "requires sign in" do
      let(:action) { post :create, leader_id: 1 }
    end
    it "redirects to the people page" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      post :create, leader_id: bob
      expect(response).to redirect_to people_path
    end
    it "it adds followed user to the current users people page" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      post :create, leader_id: bob.id
      expect(john.following_relationships.first.leader).to eq(bob)
    end
    it "does not allow current user to follow same person twice" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader_id: bob.id, follower_id: john.id)
      post :create, leader_id: bob.id
      expect(Relationship.count).to eq(1)
    end
    it "does not allow one to follow themselves" do
      john = Fabricate(:user)
      set_current_user(john)
      post :create, leader_id: john.id
      expect(Relationship.count).to eq(0)
    end
  end

  describe "DELETE destroy" do
    it_behaves_like "requires sign in" do
      let(:action) { delete :destroy, id: 4 }
    end
    it "deletes the relationship if the current user is the follower" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: john, leader: bob)
      delete :destroy, id: relationship
      expect(Relationship.count).to eq(0)
    end
    it "redirects to the people page" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: john, leader: bob)
      delete :destroy, id: relationship
      expect(response).to redirect_to people_path
    end
    it "does not delete the relationship if the current user is not the follower" do
      john = Fabricate(:user)
      set_current_user(john)
      bob = Fabricate(:user)
      don = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: don, leader: bob)
      delete :destroy, id: relationship
      expect(Relationship.count).to eq(1)
    end
  end
end
