require 'spec_helper'

describe ForgotPasswordsController do
  context "POST create" do
    context "with blank inputs" do
      it "redirects to the forgot passwords page" do
        post :create, email: ''
        expect(response).to redirect_to forgot_password_path
      end
      it "shows an error message" do
        post :create, email: ''
        expect(flash[:error]).to eq("Email cannot be blank")
      end
    end
    context "with existing email" do
      it "redirects to the forgot password page" do
        Fabricate(:user, email: 'john@yahoo.com')
        post :create, email: 'john@yahoo.com'
        expect(response).to redirect_to forgot_password_confirmation_path
      end
      it "sends out email to the email address" do
        Fabricate(:user, email: 'john@yahoo.com', password: 'password')
        post :create, email: 'john@yahoo.com'
        expect(ActionMailer::Base.deliveries.last.to).to eq(['john@yahoo.com'])
      end
    end
    context "with non-existing email" do
      it "redirects to the forgot password page" do
        post :create, email: 'john@yahoo.com'
        expect(response).to redirect_to forgot_password_path
      end
      it "shows an error message" do
        post :create, email: 'john@yahoo.com'
        expect(flash[:error]).to eq("There is no user with that email")
      end
    end
  end
end
