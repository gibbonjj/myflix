require 'spec_helper'

describe InvitationsController do
  describe "GET new" do
    it "sets @invitation to a new invitation" do
      set_current_user
      get :new
      expect(assigns(:invitation)).to be_new_record
    end
    it_behaves_like "requires sign in" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    after { ActionMailer::Base.deliveries.clear }

    it_behaves_like "requires sign in" do
      let(:action) { post :create }
    end
    context "with valid inputs" do
      it "redirects back to invite page" do
        set_current_user
        post :create, invitation: { recipient_name: "bob", recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(response).to redirect_to new_invitation_path
      end
      it "creates a new inviation" do
        set_current_user
        post :create, invitation: { recipient_name: "bob", recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(Invitation.count).to eq(1)
      end
      it "it sends an email to the recipient" do
        set_current_user
        post :create, invitation: { recipient_name: "bob", recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['bob@yahoo.com'])
      end
      it "sets the success flash message" do
        set_current_user
        post :create, invitation: { recipient_name: "bob", recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(flash[:success]).to be_present
      end
    end
    context "with invalid inputs" do
      it "renders the new template" do
        set_current_user
        post :create, invitation: { recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(response).to render_template :new
      end
      it "does not create an invitation" do
        set_current_user
        post :create, invitation: { recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(Invitation.count).to eq(0)
      end
      it "does not send out an email" do
        set_current_user
        post :create, invitation: { recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
      it "it sets @invitation" do
        set_current_user
        post :create, invitation: { recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(assigns(:invitation)).to be_present
      end
      it "sets the flash error message" do
        set_current_user
        post :create, invitation: { recipient_email: "bob@yahoo.com", message: "join ussss" }
        expect(flash[:error]).to be_present
      end
    end
  end
end
