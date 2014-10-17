require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets @user" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST create" do
    context "with valid input" do
      it "creates user" do
        post :create, user: {email: "ss@google.com", password: "password", full_name: "steve" }
        expect(User.where(full_name: "steve")).to be_truthy
      end
      it "redirects to sign_in_path" do
        post :create, user: {email: "ss@google.com", password: "password", full_name: "steve" }
        expect(response).to redirect_to sign_in_path
      end
      it "makes the user follow the inviter" do
        bob = Fabricate(:user)
        invite = Fabricate(:invitation, inviter: bob, recipient_email: "john@yahoo.com")
        post :create, user: {email: "john@yahoo.com", password: "password", full_name: "john" }, invitation_token: invite.token
        john = User.where(email: "john@yahoo.com").first
        expect(john.follows?(bob)).to be_truthy
      end
      it "makes the inviter follow the user" do
        bob = Fabricate(:user)
        invite = Fabricate(:invitation, inviter: bob, recipient_email: "john@yahoo.com")
        post :create, user: {email: "john@yahoo.com", password: "password", full_name: "john" }, invitation_token: invite.token
        john = User.where(email: "john@yahoo.com").first
        expect(bob.follows?(john)).to be_truthy
      end
      it "expires the invitation upon exceptance" do
        bob = Fabricate(:user)
        invite = Fabricate(:invitation, inviter: bob, recipient_email: "john@yahoo.com")
        post :create, user: {email: "john@yahoo.com", password: "password", full_name: "john" }, invitation_token: invite.token
        expect(Invitation.first.token).to be_nil
      end
    end
    context "sending emails" do
      after { ActionMailer::Base.deliveries.clear }
      it "sends out email to the user with valid inputs" do
        post :create, user: { email: "john@google.com", password: "password", full_name: "john" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['john@google.com'])
      end
      it "sends out email containing the users name with valid inputs" do
        post :create, user: { email: "john@google.com", password: "password", full_name: "john" }
        expect(ActionMailer::Base.deliveries.last.body).to include("john")
      end
      it "does not send out email with invalid inputs" do
        post :create, user: { password: "password", full_name: "john" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
    context "with invalid input" do
      it "does not create user" do
        post :create, user: { password: "password", full_name: "steve" }
        expect(User.where(full_name: "steve")).to be_empty
      end
      it "renders the new template" do
        post :create, user: { password: "password", full_name: "steve" }
        expect(response).to render_template :new
      end
      it "sets @user" do
        post :create, user: { password: "password", full_name: "steve" }
        expect(assigns(:user)).to be_instance_of(User)
      end
    end
  end

  describe "GET show" do
    it_behaves_like "requires sign in" do
      let(:action) { get :show, id: 3 }
    end
    it "sets @user" do
      set_current_user
      john = Fabricate(:user)
      get :show, id: john.id
      expect(assigns(:user)).to eq(john)
    end
  end

  describe "GET new_with_invitation_token" do
    it "renders the :new view template" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(response).to render_template :new
    end
    it "sets @user with recipient_email address" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end
    it "sets @invitation_token" do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end
    it "redirects to expired token page for invalid tokens" do
      get :new_with_invitation_token, token: "token"
      expect(response).to redirect_to expired_token_path
    end
  end
end
