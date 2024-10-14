require "rspec"
require "spec_helper"
require "mismatch_inspectable"

class TestClass
  include MismatchInspectable

  attr_accessor :name, :age, :address, :nested

  inspect_mismatch_for :name, :age, :address, :nested
end

class NestedTestClass
  include MismatchInspectable

  attr_accessor :city, :country

  inspect_mismatch_for :city, :country
end

RSpec.describe MismatchInspectable do
  describe "#inspect_mismatch" do
    let(:object1) { TestClass.new }
    let(:object2) { TestClass.new }
    let(:format) { :array }
    let(:recursive) { false }

    let(:name) { "Tyler" }
    let(:age) { 29 }
    let(:address) { "123 Cool St" }

    before do
      object1.name = name
      object1.age = age
      object1.address = address

      object2.name = name
      object2.age = age
      object2.address = address
    end

    context "when objects are of different classes" do
      let(:object3) { Object.new }

      it "returns nil" do
        expect(object1.inspect_mismatch(object3)).to be_nil
      end
    end

    context "when objects are of the same class" do
      context "with top level attributes that match" do
        it "returns an empty array" do
          expect(object1.inspect_mismatch(object1)).to eq([])
        end

        context "when format is set to :hash" do
          let(:format) { :hash }

          it "returns an empty hash" do
            expect(object1.inspect_mismatch(object1, format:)).to eq({})
          end
        end

        context "with nested inspectable attributes" do
          let(:recursive) { true }

          context "when objects have nested attributes with the same class" do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { NestedTestClass.new }

            let(:city) { "ATX" }
            let(:country) { "USA" }

            before do
              nested1.city = city
              nested1.country = country

              nested2.city = city
              nested2.country = country

              object1.nested = nested1
              object2.nested = nested2
            end

            context "when nested attributes match" do
              it "returns an empty array" do
                expect(object1.inspect_mismatch(object2, recursive:)).to eq([])
              end

              context "when format is set to :hash" do
                let(:format) { :hash }
                it "returns an empty hash" do
                  expect(object1.inspect_mismatch(object2, format:, recursive:)).to eq({})
                end
              end
            end

            context "when nested attributes have different values" do
              before { nested2.city = "Phoenix" }

              it "returns an array of mismatched nested attributes with recursive flag enabled" do
                expected = [
                  ["nested.NestedTestClass#city", "ATX", "Phoenix"]
                ]
                expect(object1.inspect_mismatch(object2, recursive:)).to eq(expected)
              end

              context "when format is set to :hash" do
                let(:format) { :hash }
                it "returns a hash of mismatched nested attributes with recursive flag enabled" do
                  expected = {
                    "nested.NestedTestClass#city" => %w[ATX Phoenix]
                  }
                  expect(object1.inspect_mismatch(object2, format:, recursive:)).to eq(expected)
                end
              end
            end
          end

          context "when nested attributes have different classes" do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { TestClass.new }

            before do
              object1.nested = nested1
              object2.nested = nested2
            end

            it "returns nil for mismatched nested attribute with recursive flag enabled" do
              expect(object1.inspect_mismatch(object2, recursive:)).to eq([])
            end
          end
        end
      end

      context "with top level attributes that don't match" do
        before { object2.age = 30 }

        context "when format is set to :array (default)" do
          it "returns an array of mismatched attributes" do
            expected = [
              ["TestClass#age", 29, 30]
            ]
            expect(object1.inspect_mismatch(object2)).to eq(expected)
          end
        end

        context "when format is set to :hash" do
          let(:format) { :hash }
          it "returns a hash of mismatched attributes" do
            expected = {
              "TestClass#age" => [29, 30]
            }
            expect(object1.inspect_mismatch(object2, format:)).to eq(expected)
          end
        end

        context "when format is set to :object" do
          let(:format) { :object }
          it "returns an object of mismatched attributes" do
            expected = {
              TestClass: {
                age: [29, 30]
              }
            }
            expect(object1.inspect_mismatch(object2, format:)).to eq(expected)
          end
        end

        context "with nested inspectable attributes" do
          let(:recursive) { true }
          context "when objects have nested attributes with the same class" do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { NestedTestClass.new }

            let(:city) { "ATX" }
            let(:country) { "USA" }

            before do
              nested1.city = city
              nested1.country = country

              nested2.city = "Phoenix"
              nested2.country = country

              object1.nested = nested1
              object2.nested = nested1
            end

            context "when nested attributes match" do
              context "when format is set to :array (default)" do
                it "returns the top-level mismatched attributes" do
                  expected = [
                    ["TestClass#age", 29, 30]
                  ]
                  expect(object1.inspect_mismatch(object2)).to eq(expected)
                end
              end

              context "when format is set to :hash" do
                let(:format) { :hash }
                it "returns the top-level mismatched attributes" do
                  expected = {
                    "TestClass#age" => [29, 30]
                  }
                  expect(object1.inspect_mismatch(object2, format:)).to eq(expected)
                end
              end

              context "when format is set to :object" do
                let(:format) { :object }
                it "returns the top-level mismatched attributes" do
                  expected = {
                    TestClass: {
                      age: [29, 30]
                    }
                  }
                  expect(object1.inspect_mismatch(object2, format:)).to eq(expected)
                end
              end
            end

            context "when nested attributes have different values" do
              before { object2.nested = nested2 }

              context "when format is set to :array (default)" do
                it "returns an array of mismatched nested attributes with recursive flag enabled" do
                  expected = [
                    ["TestClass#age", 29, 30],
                    ["TestClass#nested.NestedTestClass#city", "ATX", "Phoenix"]
                  ]
                  expect(object1.inspect_mismatch(object2, recursive: true)).to eq(expected)
                end
              end

              context "when format is set to :hash" do
                let(:format) { :hash }
                it "returns a hash of mismatched nested attributes with recursive flag enabled" do
                  expected = {
                    "TestClass#age" => [29, 30],
                    "TestClass#nested.NestedTestClass#city" => %w[ATX Phoenix]
                  }
                  expect(object1.inspect_mismatch(object2, recursive:, format:)).to eq(expected)
                end
              end

              context "when format is set to :object" do
                let(:format) { :object }
                it "returns an object of mismatched nested attributes with recursive flag enabled" do
                  expected = {
                    TestClass: {
                      age: [29, 30],
                      nested: {
                        NestedTestClass: {
                          city: %w[ATX Phoenix]
                        }
                      }
                    }
                  }
                  expect(object1.inspect_mismatch(object2, recursive:, format:)).to eq(expected)
                end
              end
            end
          end

          context "when nested attributes have different classes" do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { TestClass.new }

            before do
              object1.nested = nested1
              object2.nested = nested2
            end

            context "when format is set to :array (default)" do
              it "returns nil for mismatched nested attribute with recursive flag enabled" do
                expect(object1.inspect_mismatch(object2, recursive:)).to eq(
                  [
                    ["TestClass#age", 29, 30]
                  ]
                )
              end
            end

            context "when format is set to :hash" do
              let(:format) { :hash }
              it "returns nil for mismatched nested attribute with recursive flag enabled" do
                expect(object1.inspect_mismatch(object2, recursive:, format:)).to eq(
                  {
                    "TestClass#age" => [29, 30]
                  }
                )
              end
            end

            context "when format is set to :object" do
              let(:format) { :object }
              it "returns nil for mismatched nested attribute with recursive flag enabled" do
                expect(object1.inspect_mismatch(object2, recursive:, format:)).to eq(
                  {
                    TestClass: {
                      age: [29, 30]
                    }
                  }
                )
              end
            end
          end

          context "with multiple levels of nested inspectable attributes" do
            # rubocop:disable Lint/ConstantDefinitionInBlock
            class Thing
              include MismatchInspectable

              inspect_mismatch_for :color, :shape, :is_cool, :nested_thing

              def initialize(color: nil, shape: nil, is_cool: nil, nested_thing: nil)
                @color = color
                @shape = shape
                @is_cool = is_cool
                @nested_thing = nested_thing
              end

              def inspect
                "<Thing>"
              end

              attr_accessor :color, :shape, :is_cool, :nested_thing
            end
            # rubocop:enable Lint/ConstantDefinitionInBlock

            let(:thing1) do
              Thing.new(
                color: "blue",
                shape: "square",
                is_cool: false,
                nested_thing: Thing.new(
                  color: "blue",
                  shape: "oval",
                  is_cool: true,
                  nested_thing: Thing.new(
                    color: "silver",
                    shape: "oval",
                    is_cool: true
                  )
                )
              )
            end

            let(:thing2) do
              Thing.new(
                color: "green",
                shape: "oval",
                is_cool: false,
                nested_thing: Thing.new(
                  color: "red",
                  shape: "another shape",
                  is_cool: true,
                  nested_thing: Thing.new(
                    color: "blue",
                    shape: "oval",
                    is_cool: false
                  )
                )
              )
            end
            context "with recursive flag disabled" do
              it "returns the mismatched top-level attributes" do
                expect(thing1.inspect_mismatch(thing2, format: :object)).to eq(
                  {
                    Thing: {
                      color: %w[blue green],
                      shape: %w[square oval],
                      nested_thing: [thing1.nested_thing, thing2.nested_thing] # [<Thing>, <Thing>]
                    }
                  }
                )
              end
            end

            context "with recursive flag enabled" do
              let(:recursive) { true }
              it "returns the mismatched attributes with the appropriate nesting" do
                expect(thing1.inspect_mismatch(thing2, recursive:, format: :object)).to eq(
                  {
                    Thing: {
                      color: %w[blue green],
                      shape: %w[
                        square oval
                      ],
                      nested_thing: {
                        Thing: {
                          color: %w[blue red],
                          shape: ["oval", "another shape"],
                          nested_thing: {
                            Thing: {
                              color: %w[silver blue],
                              is_cool: [true, false]
                            }
                          }
                        }
                      }
                    }
                  }
                )
              end
            end
          end
        end
      end
    end
  end

  describe ".diff" do
    context "with primitive objects" do
      context "when the objects are not equal" do
        let(:object1) { 1 }
        let(:object2) { 2 }

        specify do
          expect(MismatchInspectable.diff(object1, object2)).to eq([["", 1, 2]])
        end
      end
      context "when the objects are equal" do
        let(:object1) { 1 }
        let(:object2) { object1 }

        specify do
          expect(MismatchInspectable.diff(object1, object2)).to eq([])
        end
      end

      context "when the classes do not match" do
        let(:object1) { 1 }
        let(:object2) { "1" }

        specify do
          expect(MismatchInspectable.diff(object1, object2)).to eq([["", 1, "1"]])
        end
      end
    end

    context "with enemerable objects" do
      context "with arrays" do
        context "with diff values" do
          let(:object1) { [1, 2, 3] }
          let(:object2) { [1, 2, 4] }

          specify do
            expect(MismatchInspectable.diff(object1, object2)).to eq([["[2]", 3, 4]])
          end
        end

        context 'with diff lengths' do
          let(:object1) { [1, 2, 3] }
          let(:object2) { [1, 2] }

          specify do
            expect(MismatchInspectable.diff(object1, object2)).to eq([["#length", 3, 2]])
          end
        end
      end
    end
  end
end
