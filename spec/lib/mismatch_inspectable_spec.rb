require 'rspec'
require 'spec_helper'
require 'mismatch_inspectable'

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
  let(:object1) { TestClass.new }
  let(:object2) { TestClass.new }
  let(:format) { :array }
  let(:recursive) { false }

  let(:name) { 'Tyler' }
  let(:age) { 29 }
  let(:address) { '123 Cool St' }

  before do
    object1.name = name
    object1.age = age
    object1.address = address

    object2.name = name
    object2.age = age
    object2.address = address
  end

  describe '#inspect_mismatch' do
    context 'when objects are of different classes' do
      let(:object3) { Object.new }

      it 'returns nil' do
        expect(object1.inspect_mismatch(object3)).to be_nil
      end
    end

    context 'when objects are of the same class' do
      context 'with top level attributes that match' do
        it 'returns an empty array' do
          expect(object1.inspect_mismatch(object1)).to eq([])
        end

        context 'when format is set to :hash' do
          let(:format) { :hash }

          it 'returns an empty hash' do
            expect(object1.inspect_mismatch(object1, format: format)).to eq({})
          end
        end

        context 'with nested inspectable attributes' do
          let(:recursive) { true }

          context 'when objects have nested attributes with the same class' do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { NestedTestClass.new }

            let(:city) { 'ATX' }
            let(:country) { 'USA' }

            before do
              nested1.city = city
              nested1.country = country

              nested2.city = city
              nested2.country = country

              object1.nested = nested1
              object2.nested = nested2
            end

            context 'when nested attributes match' do
              it 'returns an empty array' do
                expect(object1.inspect_mismatch(object2, recursive: recursive)).to eq([])
              end

              context 'when format is set to :hash' do
                let(:format) { :hash }
                it 'returns an empty hash' do
                  expect(object1.inspect_mismatch(object2, format: format, recursive: recursive)).to eq({})
                end
              end
            end

            context 'when nested attributes have different values' do
              before { nested2.city = 'Phoenix' }

              it 'returns an array of mismatched nested attributes with recursive flag enabled' do
                expected = [
                  ['nested.NestedTestClass#city', 'ATX', 'Phoenix']
                ]
                expect(object1.inspect_mismatch(object2, recursive: recursive)).to eq(expected)
              end

              context 'when format is set to :hash' do
                let(:format) { :hash }
                it 'returns a hash of mismatched nested attributes with recursive flag enabled' do
                  expected = {
                    'nested.NestedTestClass#city' => %w[ATX Phoenix]
                  }
                  expect(object1.inspect_mismatch(object2, format: format, recursive: recursive)).to eq(expected)
                end
              end
            end
          end

          context 'when nested attributes have different classes' do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { TestClass.new }

            before do
              object1.nested = nested1
              object2.nested = nested2
            end

            it 'returns nil for mismatched nested attribute with recursive flag enabled' do
              expect(object1.inspect_mismatch(object2, recursive: recursive)).to eq([])
            end
          end
        end
      end

      context "with top level attributes that don't match" do
        before { object2.age = 30 }

        context 'when format is set to :array (default)' do
          it 'returns an array of mismatched attributes' do
            expected = [
              ['TestClass#age', 29, 30]
            ]
            expect(object1.inspect_mismatch(object2)).to eq(expected)
          end
        end

        context 'when format is set to :hash' do
          let(:format) { :hash }
          it 'returns a hash of mismatched attributes' do
            expected = {
              'TestClass#age' => [29, 30]
            }
            expect(object1.inspect_mismatch(object2, format: format)).to eq(expected)
          end
        end

        context 'when format is set to :object' do
          let(:format) { :object }
          it 'returns an object of mismatched attributes' do
            expected = {
              TestClass: {
                age: [29, 30]
              }
            }
            expect(object1.inspect_mismatch(object2, format: format)).to eq(expected)
          end
        end

        context 'with nested inspectable attributes' do
          let(:recursive) { true }
          context 'when objects have nested attributes with the same class' do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { NestedTestClass.new }

            let(:city) { 'ATX' }
            let(:country) { 'USA' }

            before do
              nested1.city = city
              nested1.country = country

              nested2.city = 'Phoenix'
              nested2.country = country

              object1.nested = nested1
              object2.nested = nested1
            end

            context 'when nested attributes match' do
              context 'when format is set to :array (default)' do
                it 'returns the top-level mismatched attributes' do
                  expected = [
                    ['TestClass#age', 29, 30]
                  ]
                  expect(object1.inspect_mismatch(object2)).to eq(expected)
                end
              end

              context 'when format is set to :hash' do
                let(:format) { :hash }
                it 'returns the top-level mismatched attributes' do
                  expected = {
                    'TestClass#age' => [29, 30]
                  }
                  expect(object1.inspect_mismatch(object2, format: format)).to eq(expected)
                end
              end

              context 'when format is set to :object' do
                let(:format) { :object }
                it 'returns the top-level mismatched attributes' do
                  expected = {
                    TestClass: {
                      age: [29, 30]
                    }
                  }
                  expect(object1.inspect_mismatch(object2, format: format)).to eq(expected)
                end
              end
            end

            context 'when nested attributes have different values' do
              before { object2.nested = nested2 }

              context 'when format is set to :array (default)' do
                it 'returns an array of mismatched nested attributes with recursive flag enabled' do
                  expected = [
                    ['TestClass#age', 29, 30],
                    ['TestClass#nested.NestedTestClass#city', 'ATX', 'Phoenix']
                  ]
                  expect(object1.inspect_mismatch(object2, recursive: true)).to eq(expected)
                end
              end

              context 'when format is set to :hash' do
                let(:format) { :hash }
                it 'returns a hash of mismatched nested attributes with recursive flag enabled' do
                  expected = {
                    'TestClass#age' => [29, 30],
                    'TestClass#nested.NestedTestClass#city' => %w[ATX Phoenix]
                  }
                  expect(object1.inspect_mismatch(object2, recursive: recursive, format: format)).to eq(expected)
                end
              end

              context 'when format is set to :object' do
                let(:format) { :object }
                it 'returns an object of mismatched nested attributes with recursive flag enabled' do
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
                  expect(object1.inspect_mismatch(object2, recursive: recursive, format: format)).to eq(expected)
                end
              end
            end
          end

          context 'when nested attributes have different classes' do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { TestClass.new }

            before do
              object1.nested = nested1
              object2.nested = nested2
            end

            context 'when format is set to :array (default)' do
              it 'returns nil for mismatched nested attribute with recursive flag enabled' do
                expect(object1.inspect_mismatch(object2, recursive: recursive)).to eq(
                  [
                    ['TestClass#age', 29, 30]
                  ]
                )
              end
            end

            context 'when format is set to :hash' do
              let(:format) { :hash }
              it 'returns nil for mismatched nested attribute with recursive flag enabled' do
                expect(object1.inspect_mismatch(object2, recursive: recursive, format: format)).to eq(
                  {
                    'TestClass#age' => [29, 30]
                  }
                )
              end
            end

            context 'when format is set to :object' do
              let(:format) { :object }
              it 'returns nil for mismatched nested attribute with recursive flag enabled' do
                expect(object1.inspect_mismatch(object2, recursive: recursive, format: format)).to eq(
                  {
                    TestClass: {
                      age: [29, 30]
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
end
