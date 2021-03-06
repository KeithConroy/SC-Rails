require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
  login_admin

  let(:organization){ Organization.first }
  let(:room){ create(:room, organization_id: organization.id) }
  let(:instructor){ create(:instructor, organization_id: organization.id) }
  let(:four_hour_event){ create(:event, instructor_id: instructor.id, organization_id: organization.id, start: DateTime.now, finish: DateTime.now + 4.hours) }

  context 'GET index' do
    before { get :index, organization_id: organization.id }
    it "should get index" do
      expect(response).to be_ok
      expect(response).to render_template("index")
    end
    it "gets rooms" do
      expect(assigns(:rooms)).to be_a(ActiveRecord::Relation)
    end
    it "assigns a room" do
      expect(assigns(:new_room)).to be_a(Room)
    end
  end

  context 'GET new' do
    before { get :new, organization_id: organization.id }
    it "should get new" do
      expect(response).to be_ok
      expect(response).to render_template("new")
      expect(assigns(:room)).to be_a(Room)
    end
  end

  context "POST create" do
    it "saves a new room and redirects" do
      expect{ post :create, room: {title: "room", organization_id: organization.id}, organization_id: organization.id }.to change{Room.count}.by 1
      expect(response.status).to eq 302
    end
    it "does not saves a new room with invalid input - no title" do
      expect{ post :create, room: {title: ""}, organization_id: organization.id }.to_not change{Room.count}
    end
  end

  context "GET #show" do
    before { get :show, organization_id: organization.id, id: room.id }
    it "should get show" do
      expect(response).to be_ok
      expect(response).to render_template("show")
    end
    it "gets room" do
      expect(assigns(:room)).to be_a(Room)
    end
    it "renders 404 with invalid room" do
      get :show, organization_id: organization.id, id: 42
      expect(response.status).to eq 404
    end
  end

  context "GET #edit" do
    before { get :edit, organization_id: organization.id, id: room.id }
    it "gets room" do
      expect(assigns(:room)).to be_a(Room)
    end
    it "renders 404 with invalid room" do
      get :edit, organization_id: organization.id, id: 42
      expect(response.status).to eq 404
    end
  end

  context "PUT #update" do
    context "valid update" do
      before { put :update, organization_id: organization.id, id: room.id, room: {title: "Updated room"} }
      it "gets room" do
        expect(assigns(:room)).to be_a(Room)
      end
      it "updates the room" do
        expect(Room.first.title).to match(/Updated room/)
      end
      it "should redirect" do
        expect(response.status).to eq 302
      end
    end

    context "invalid update" do
      before { put :update, organization_id: organization.id, id: room.id, room: {title: ""} }
      it "should not update" do
        expect(Room.first.title).to match(//)
      end
      it "should give an error status" do
        expect(response.status).to eq 400
      end
      it "will not update organization_id" do
        put :update, organization_id: organization.id, id: room.id, room: {organization_id: 123}
        expect(room.organization_id).to_not eq(123)
      end
      it "renders 404 with invalid room" do
        put :update, organization_id: organization.id, id: 42, room: {title: "Updated room"}
        expect(response.status).to eq 404
      end
    end
  end

  context "DELETE #destroy" do
    before { delete :destroy, organization_id: organization.id, id: room.id }
    it "gets room" do
      expect(assigns(:room)).to be_a(Room)
    end
    it "destroys the room" do
      expect(Room.count).to eq 0
    end
    it "should redirect" do
      expect(response.status).to eq 302
    end
    it "renders 404 with invalid room" do
      delete :destroy, organization_id: organization.id, id: 42
      expect(response.status).to eq 404
    end
  end

  context "GET #search" do
    before { post :create, room: {title: "Room 100", organization_id: organization.id}, organization_id: organization.id }
    before { post :create, room: {title: "Room 101", organization_id: organization.id}, organization_id: organization.id }
    before { post :create, room: {title: "L&D", organization_id: organization.id}, organization_id: organization.id }

    context 'valid search: full title match' do
      before { get :search, organization_id: organization.id, phrase: 'room 100' }
      it "calls Room.search" do
        expect(Room).to respond_to(:search).with(2).argument
      end
      it "gets rooms" do
        expect(assigns(:rooms)).to be_a(ActiveRecord::Relation)
      end
      it "finds a match" do
        expect(assigns(:rooms)).not_to be_empty
        expect(assigns(:rooms).length).to eq(1)
        expect(assigns(:rooms).first.title).to eq("Room 100")
      end
    end
    context 'valid search: partial match' do
      before { get :search, organization_id: organization.id, phrase: 'room' }
      it "finds two matches" do
        expect(assigns(:rooms).length).to eq(2)
        expect(assigns(:rooms).first.title).to eq("Room 100")
        expect(assigns(:rooms).last.title).to eq("Room 101")
      end
    end
    context 'invalid search' do
      before { get :search, organization_id: organization.id, phrase: 'abc' }
      it "returns empty" do
        expect(assigns(:rooms)).to be_empty
      end
    end
    context 'empty search' do
      before { get :search, organization_id: organization.id }
      it "gets all rooms" do
        expect(assigns(:rooms).length).to eq(3)
      end
    end
  end

  context "GET #heatmap" do
    before { four_hour_event.rooms << room }
    before { get :heatmap, organization_id: organization.id, id: room.id }
    it "should get heatmap" do
      expect(response).to be_ok
      body = JSON.parse(response.body)
      expect(body["data"]).to be_a(Hash)
      expect(body["name"]).to be_a(Array)
      expect(body["legend"]).to be_a(Array)
    end
    it "gets heatmap data" do
      get :heatmap, organization_id: organization.id, id: room.id
      body = JSON.parse(response.body)
      expect(body["data"][four_hour_event.start.to_i.to_s]).to eq(4)
      expect(body["name"]).to eq(["hour", "hours"])
    end
    it "renders 404 with invalid room" do
      get :heatmap, organization_id: organization.id, id: 42
      expect(response.status).to eq 404
    end
  end
end
