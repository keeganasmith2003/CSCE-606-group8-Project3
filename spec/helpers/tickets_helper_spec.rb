require 'rails_helper'

RSpec.describe TicketsHelper, type: :helper do
  before do
    allow_any_instance_of(User).to receive(:display_name).and_return("Alice")
  end

  let(:user) { create(:user) }

  def build_version(event:, whodunnit:, changeset: {})
    double(
      event: event,
      whodunnit: whodunnit,
      changeset: changeset
    )
  end

  describe "#render_activity_log" do
    context "when event is create" do
      it "returns ticket created message" do
        version = build_version(event: "create", whodunnit: user.id)
        expect(helper.render_activity_log(version))
          .to eq("Ticket Created by Alice")
      end
    end

    context "when changeset is empty" do
      it "returns generic update message" do
        version = build_version(event: "update", whodunnit: user.id, changeset: {})
        expect(helper.render_activity_log(version))
          .to eq("Updated by Alice")
      end
    end

    context "when status changes" do
      it "renders status change" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "status" => [ "open", "closed" ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Status changed to <strong>Closed</strong> by Alice")
      end
    end

    context "when priority changes" do
      it "renders priority change" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "priority" => [ "low", "high" ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Priority set to <strong>High</strong> by Alice")
      end
    end

    context "when assignee changes" do
      let(:agent) { create(:user) }

      it "renders assignment to agent" do
        allow_any_instance_of(User).to receive(:display_name).and_return("Alice")


        allow(User).to receive(:find_by).and_call_original
        allow(User).to receive(:find_by).with(id: agent.id).and_return(agent)
        allow(agent).to receive(:display_name).and_return("Bob")

        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "assignee_id" => [ nil, agent.id ] }
        )

        expect(helper.render_activity_log(version))
          .to eq("Assigned to <strong>Bob</strong> by Alice")
      end


      it "renders unassignment" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "assignee_id" => [ 10, nil ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("<strong>Unassigned</strong> by Alice")
      end
    end

    context "when team changes" do
      let(:team) { create(:team, name: "Support") }

      it "renders escalation" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "team_id" => [ nil, team.id ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Escalated to <strong>Support</strong> by Alice")
      end

      it "renders removal" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "team_id" => [ 5, nil ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Removed from Team by Alice")
      end
    end

    context "when closed_at changes" do
      it "renders resolved" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "closed_at" => [ nil, Time.now ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Marked as <strong>Resolved</strong> by Alice")
      end

      it "renders reopened" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "closed_at" => [ Time.now, nil ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Reopened by Alice")
      end
    end

    context "when unknown fields change" do
      it "renders fallback" do
        version = build_version(
          event: "update",
          whodunnit: user.id,
          changeset: { "description" => [ "old", "new" ] }
        )
        expect(helper.render_activity_log(version))
          .to eq("Updated Description by Alice")
      end
    end
  end
end
