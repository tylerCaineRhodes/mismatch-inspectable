require 'rspec'
require 'spec_helper'
require 'mismatch_inspectable/mismatch_inspectable'

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
          it 'returns an empty hash' do
            expect(object1.inspect_mismatch(object1, format: :hash)).to eq({})
          end
        end

        context 'with nested inspectable attributes' do
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
                expect(object1.inspect_mismatch(object2, recursive: true)).to eq([])
              end
            end

            context 'when nested attributes have different values' do
              before { nested2.city = 'Phoenix' }

              it 'returns an array of mismatched nested attributes with recursive flag enabled' do
                expected = [
                  ['TestClass#nested.NestedTestClass#city', 'ATX', 'Phoenix']
                ]
                expect(object1.inspect_mismatch(object2, recursive: true)).to eq(expected)
              end
            end
          end

          context 'when nested attributes have different classes' do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { Object.new }

            before do
              object1.nested = nested1
              object2.nested = nested2
            end

            it 'returns nil for mismatched nested attribute with recursive flag enabled' do
              pending 'need to figure out how to implement this'
              expect(object1.inspect_mismatch(object2, recursive: true)).to be_nil
            end
          end
        end
      end

      context "with top level attributes that don't match" do
        before { object2.age = 30 }

        context "when format is set to :array (default)" do
          it 'returns an array of mismatched attributes' do
            expected = [
              ['TestClass#age', 29, 30]
            ]
            expect(object1.inspect_mismatch(object2)).to eq(expected)
          end
        end

        context "when format is set to :hash" do
          it 'returns a hash of mismatched attributes' do
            expected = {
              'TestClass#age' => [29, 30]
            }
            expect(object1.inspect_mismatch(object2, format: :hash)).to eq(expected)
          end
        end

        context 'with nested inspectable attributes' do
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
              context "when format is set to :array (default)" do
                pending "need to figure out how to implement this"
                it 'returns the top-level mismatched attributes' do
                  expected = [
                    ['TestClass#age', 29, 30]
                  ]
                  expect(object1.inspect_mismatch(object2)).to eq(expected)
                end
              end

              context "when format is set to :hash" do
                pending "need to figure out how to implement this"
                it 'returns the top-level mismatched attributes' do
                  expected = {
                    'TestClass#age' => [29, 30]
                  }
                  expect(object1.inspect_mismatch(object2, format: :hash)).to eq(expected)
                end
              end
            end

            context 'when nested attributes have different values' do
              before { nested2.city = 'Phoenix' }

              context "when format is set to :array (default)" do
                pending "need to figure out how to implement this"
                it 'returns an array of mismatched nested attributes with recursive flag enabled' do
                  expected = [
                    ['TestClass#age', 29, 30],
                    ['TestClass#nested.NestedTestClass#city', 'ATX', 'Phoenix']
                  ]
                  expect(object1.inspect_mismatch(object2, recursive: true)).to eq(expected)
                end
              end

              context "when format is set to :hash" do
                it 'returns a hash of mismatched nested attributes with recursive flag enabled' do
                  expected = {
                    'TestClass#age' => [29, 30],
                    'TestClass#nested.NestedTestClass#city' => ['ATX', 'Phoenix']
                  }
                  expect(object1.inspect_mismatch(object2, format: :hash)).to eq(expected)
                end
              end
            end
          end

          context 'when nested attributes have different classes' do
            let(:nested1) { NestedTestClass.new }
            let(:nested2) { Object.new }

            before do
              object1.nested = nested1
              object2.nested = nested2
            end

            it 'returns nil for mismatched nested attribute with recursive flag enabled' do
              pending 'need to figure out how to implement this'
              expect(object1.inspect_mismatch(object2, recursive: true)).to be_nil
            end
          end
        end
      end
    end
  end
end
