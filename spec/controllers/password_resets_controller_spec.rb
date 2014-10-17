require 'spec_helper'

describe PasswordResetsController do
  describe "GET show" do
    it "renders show template if the token is valid" do
      john = Fabricate(:user)
      john.update_column(:token, "123")
      get :show, id: "123"
      expect(response).to render_template :show
    end
    it "sets token" do
      john = Fabricate(:user)
      john.update_column(:token, "123")
      get :show, id: "123"
      expect(assigns(:token)).to eq("123")
    end
    it "redirects to the expired token page if the  token is not valid" do
      get :show, id: "123"
      expect(response).to redirect_to expired_token_path
    end
  end
  describe "POST create" do
    context "with valid token" do
      it "redirects to user sign in page" do
        john = Fabricate(:user, password: "password")
        john.update_column(:token, "123")
        post :create, token: "123", password: "new_password"
        expect(response).to redirect_to sign_in_path
      end
      it "updates users password" do
        john = Fabricate(:user, password: "password")
        john.update_column(:token, "123")
        post :create, token: "123", password: "new_password"
        expect(john.reload.authenticate("new_password")).to be_truthy
      end
      it "sets the flash success message" do
        john = Fabricate(:user, password: "password")
        john.update_column(:token, "123")
        post :create, token: "123", password: "new_password"
        expect(flash[:success]).to eq("Password updated")
      end
      it "regenerates users token" do
        john = Fabricate(:user, password: "password")
        john.update_column(:token, "123")
        post :create, token: "123", password: "new_password"
        expect(john.reload.token).not_to eq("123")
      end
    end
    context "with invalid token" do
      it "redirects to the expired token path" do
        post :create, token: "123", password: "new_password"
        expect(response).to redirect_to expired_token_path
      end
    end
  end
end
