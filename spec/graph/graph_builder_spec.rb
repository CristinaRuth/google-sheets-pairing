# frozen_string_literal: true

require "spec_helper"
require "mentor"
require "mentee"
require "graph/graph_builder"

RSpec.describe GraphBuilder, type: :model do
  let(:mentors) { [
      Mentor.new("s1", ["a", "b"]),
      Mentor.new("s2", ["c"]),
      Mentor.new("s3", ["a", "d"])
    ] }
  let(:mentees) { [
      Mentee.new("p1", "a"),
      Mentee.new("p2", "b"),
      Mentee.new("p3", "b"),
      Mentee.new("p4", "c")
    ] }

# expected:
# s1 : p1
# s1 : p2
# s1 : p3
# s2 : p4
# s3 : p1

  subject { described_class.new(mentors, mentees) }
  describe "#build" do
    it "creates a graph with the expected shape" do
      graph = subject.build
      expect(graph.nodes.length).to eq(7)
      expect(graph.edges.length).to eq(5)
      expect(graph["s1"].edges.length).to eq(3)
      expect(graph["s2"].edges.length).to eq(1)
      expect(graph["s3"].edges.length).to eq(1)
    end
  end
end
