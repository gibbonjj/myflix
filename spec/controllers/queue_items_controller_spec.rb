require 'spec_helper'

describe QueueItemsController do
  describe "GET index" do
    it "sets @queue_items to the queues of the logged in user" do
      john = Fabricate(:user)
      set_current_user(john)
      queue1 = Fabricate(:queue_item, user: john)
      queue2 = Fabricate(:queue_item, user: john)
      get :index
      expect(assigns(:queue_items)).to match_array([queue1, queue2])
    end

    it_behaves_like "requires sign in" do
      let(:action) { get :index }
    end
  end

  describe "POST create" do
    it "redirects to my queue path" do
      set_current_user
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end
    it "creates a queue item" do
      set_current_user
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end
    it "creates a queue item that is associated with a video" do
      set_current_user
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end
    it "creates a queue item associated with signed in user" do
      john = Fabricate(:user)
      set_current_user(john)
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.user).to eq(john)
    end
    it "puts the video as the last on in the queue" do
      john = Fabricate(:user)
      set_current_user(john)
      monk = Fabricate(:video)
      Fabricate(:queue_item, video: monk, user: john)
      south_park = Fabricate(:video)
      post :create, video_id: south_park.id
      south_park_queue_item = QueueItem.where(video_id: south_park.id, user_id: john.id).first
      expect(south_park_queue_item.position).to eq(2)
    end
    it "it does not add video to queue if the video is already in queue" do
      john = Fabricate(:user)
      set_current_user(john)
      monk = Fabricate(:video)
      Fabricate(:queue_item, video: monk, user: john)
      post :create, video_id: monk.id
      expect(john.queue_items.count).to eq(1)
    end
    it_behaves_like "requires sign in" do
      let(:action) { post :create, video_id: 3 }
    end
  end
  describe "POST update_queue" do
    context "with valid inputs" do

      let(:john) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: john, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: john, position: 2, video: video) }

      before { set_current_user(john) }

      it "redirects to my queue page" do
        post :update_queue, queue_items: [{id: queue_item1, position: 2}, {id: queue_item2, position: 1}]
        expect(response).to redirect_to my_queue_path
      end
      it "reorders the queue items" do
        post :update_queue, queue_items: [{id: queue_item1, position: 2}, {id: queue_item2, position: 1}]
        expect(john.queue_items).to eq([queue_item2, queue_item1])
      end
      it "normalizes position numbers" do
        post :update_queue, queue_items: [{id: queue_item1, position: 3}, {id: queue_item2, position: 2}]
        expect(john.queue_items.map(&:position)).to eq([1,2])
      end
    end
    context "with invalid inputs" do

      let(:john) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: john, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: john, position: 2, video: video) }

      before { set_current_user(john) }

      it "redirects to my queue page" do
        post :update_queue, queue_items: [{id: queue_item1, position: nil}, {id: queue_item2, position: 2}]
        expect(response).to redirect_to my_queue_path
      end
      it "it sets the flash error message" do
        post :update_queue, queue_items: [{id: queue_item1, position: 3.3}, {id: queue_item2, position: 2}]
        expect(flash[:error]).to be_present
      end
      it "does not change the queue items" do
        post :update_queue, queue_items: [{id: queue_item1, position: 3}, {id: queue_item2, position: 2.1}]
        expect(queue_item1.reload.position).to eq(1)
      end
    end
    context "with unauthenticated user" do
      it_behaves_like "requires sign in" do
        let(:action) { post :update_queue }
      end
    end
    context "with queue items that does not belong to current user" do
      it "should not change the queue items" do
        john = Fabricate(:user)
        bob = Fabricate(:user)
        set_current_user(john)
        video = Fabricate(:video)
        queue_item1 = Fabricate(:queue_item, user: bob, position: 1, video: video)
        queue_item2 = Fabricate(:queue_item, user: john, position: 2, video: video)
        post :update_queue, queue_items: [{id: queue_item1, position: 2}, {id: queue_item2, position: 1}]
        expect(queue_item1.reload.position).to eq(1)
      end
    end
  end

  describe "DELETE destroy" do
    it "deletes queue item from my queue" do
      john = Fabricate(:user)
      set_current_user(john)
      queue_item = Fabricate(:queue_item, user: john)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end
    it "redirects to my queue path" do
      set_current_user
      queue_item = Fabricate(:queue_item)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to my_queue_path
    end
    it "does not delete the queue item if the queue item is not in current user queue" do
      john = Fabricate(:user)
      set_current_user(john)
      adams = Fabricate(:user)
      queue_item = Fabricate(:queue_item, user: adams)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(1)
    end
    it "it normalizes the remaining queues" do
      john = Fabricate(:user)
      set_current_user(john)
      queue_item1 = Fabricate(:queue_item, user: john, position: 1)
      queue_item2 = Fabricate(:queue_item, user: john, position: 2)
      delete :destroy, id: queue_item1.id
      expect(queue_item2.reload.position).to eq(1)
    end
    it_behaves_like "requires sign in" do
      let(:action) { delete :destroy, id: 3 }
    end
  end
end
