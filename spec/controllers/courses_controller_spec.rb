require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:organization) do
    Organization.create!(
      title: "University",
      subdomain: "uni"
    )
  end
  let(:instructor) do
    User.create!(
      first_name: "Keith",
      last_name: "Conroy",
      email: "keith@mail.com",
      organization_id: organization.id,
      is_student: false,
    )
  end
  let(:student) do
    User.create!(
      first_name: "Test",
      last_name: "Student",
      email: "student@mail.com",
      organization_id: organization.id,
      is_student: true,
    )
  end
  let(:course) do
    Course.create!(
      title: "Test Course",
      instructor_id: instructor.id,
      organization_id: organization.id,
    )
  end
  context 'GET index' do
    before { get :index, organization_id: organization.id }
    it "should get index" do
      expect(response).to be_ok
      expect(response).to render_template("index")
    end
    it "gets courses" do
      expect(assigns(:courses)).to be_a(ActiveRecord::Relation)
    end
    it "assigns a course" do
      expect(assigns(:new_course)).to be_a(Course)
    end
  end

  context "POST create" do
    it "saves a new course and redirects" do
      expect{ post :create, course: {title: "Course", instructor_id: instructor.id, organization_id: organization.id}, organization_id: organization.id }.to change{Course.count}.by 1
      expect(response.status).to eq 302
    end
    it "does not saves a new course with invalid input" do
      expect{ post :create, course: {title: ""}, organization_id: organization.id }.to_not change{Course.count}
    end
  end

  context "GET #show" do
    before { get :show, organization_id: organization.id, id: course.id }
    it "should get show" do
      expect(response).to be_ok
      expect(response).to render_template("show")
    end
    it "gets course" do
      expect(assigns(:course)).to be_a(Course)
    end
  end

  context "GET #edit" do
    before { get :edit, organization_id: organization.id, id: course.id }
    it "gets course" do
      expect(assigns(:course)).to be_a(Course)
    end
  end

  context "PUT #update" do
    context "valid update" do
      before { put :update, organization_id: organization.id, id: course.id, course: {title: "Updated Course"} }
      it "gets course" do
        expect(assigns(:course)).to be_a(Course)
      end
      it "updates the course" do
        expect(Course.first.title).to match(/Updated Course/)
      end
      it "should redirect" do
        expect(response.status).to eq 302
      end
    end

    context "invalid update" do
      before { put :update, organization_id: organization.id, id: course.id, course: {title: ""} }
      it "should not update" do
        expect(Course.first.title).to match(//)
      end
      it "should give an error status" do
        expect(response.status).to eq 400
      end
    end
  end

  context "DELETE #destroy" do
    before { delete :destroy, organization_id: organization.id, id: course.id }
    it "gets course" do
      expect(assigns(:course)).to be_a(Course)
    end
    it "destroys the course" do
      expect(Course.count).to eq 0
    end
    it "should redirect" do
      expect(response.status).to eq 302
    end
  end

  context "POST #add_student" do
    before { post :add_student, organization_id: organization.id, course_id: course.id, id: student.id }
    it "gets course" do
      expect(assigns(:course)).to be_a(Course)
    end
    it "gets student" do
      expect(assigns(:student)).to be_a(User)
    end
    it "assigns the student to the course" do
      expect(Course.first.students).to include(student)
    end
  end

  context "DELETE #remove_student" do
    before { post :add_student, organization_id: organization.id, course_id: course.id, id: student.id }
    before { post :remove_student, organization_id: organization.id, course_id: course.id, id: student.id }
    it "gets course" do
      expect(assigns(:course)).to be_a(Course)
    end
    it "gets student" do
      expect(assigns(:student)).to be_a(User)
    end
    it "remove the student from the course" do
      expect(Course.first.students).to_not include(student)
    end
  end

  context "GET #search" do
    before { get :search, organization_id: organization.id, phrase: 'Course' }
    it "gets courses" do
      expect(assigns(:courses)).to be_a(ActiveRecord::Relation)
    end
  end

  context "GET #modify_search" do
    before { get :modify_search, organization_id: organization.id, course_id: course.id, phrase: 'Course' }
    it "modify searches"
  end
end