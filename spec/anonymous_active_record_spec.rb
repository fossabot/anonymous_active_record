RSpec.describe AnonymousActiveRecord do
  it 'has a version number' do
    expect(AnonymousActiveRecord::VERSION).not_to be nil
  end

  describe '.generate' do
    context 'minimal params' do
      subject { described_class.generate() }
      it 'does not error' do
        expect { subject }.to_not raise_error
      end
      context 'instance' do
        subject { super().new }
        it 'can be instantiated' do
          is_expected.to be_a(ActiveRecord::Base)
        end
        context 'timestamps' do
          it 'has' do
            expect(subject.created_at).to be_nil
            expect(subject.updated_at).to be_nil
          end
        end
        context 'saving' do
          subject do
            i = super()
            i.save
            i
          end
          it 'does not error' do
            expect { subject }.to_not raise_error
          end
          it 'does not have name' do
            expect(subject).to_not respond_to(:name)
          end
          it 'sets timestamps' do
            expect(subject.created_at).to_not be_nil
            expect(subject.updated_at).to_not be_nil
          end
        end
      end
    end
    context 'all params' do
      let!(:farm_animal) {
        module Farm
          module Animal
          end
        end
      }
      let(:table_name) { 'dogs' }
      let(:klass_namespaces) { %w[Farm Animal] }
      let(:klass_basename) { 'my' }
      let(:columns) { ['name'] }
      let(:timestamps) { true }
      let(:connection_params) { AnonymousActiveRecord::DEFAULT_CONNECTION_PARAMS }
      subject { described_class.generate(
          table_name: table_name,
          klass_namespaces: klass_namespaces,
          klass_basename: klass_basename,
          columns: columns,
          timestamps: timestamps,
          connection_params: connection_params)
      }
      it 'does not error' do
        expect { subject }.to_not raise_error
      end
      context 'instance' do
        subject { super().new }
        it 'can be instantiated' do
          is_expected.to be_a(ActiveRecord::Base)
        end
        context 'name' do
          it 'has' do
            expect(subject.name).to be_nil
          end
        end
        context 'timestamps' do
          it 'has' do
            expect(subject.created_at).to be_nil
            expect(subject.updated_at).to be_nil
          end
        end
        context 'saving' do
          subject do
            i = super()
            i.name = 'Bobo'
            i.save
            i
          end
          it 'does not error' do
            expect { subject }.to_not raise_error
          end
          it 'sets name' do
            expect(subject.name).to eq('Bobo')
          end
          it 'sets timestamps' do
            expect(subject.created_at).to_not be_nil
            expect(subject.updated_at).to_not be_nil
          end
        end
      end
    end
    context 'no timestamps' do
      let(:table_name) { 'dogs' }
      let(:klass_basename) { 'my' }
      let(:columns) { ['name'] }
      let(:timestamps) { false }
      let(:connection_params) { AnonymousActiveRecord::DEFAULT_CONNECTION_PARAMS }
      subject { described_class.generate(
          table_name: table_name,
          klass_basename: klass_basename,
          columns: columns,
          timestamps: timestamps,
          connection_params: connection_params)
      }
      it 'does not error' do
        expect { subject }.to_not raise_error
      end
      context 'instance' do
        subject { super().new }
        it 'can be instantiated' do
          is_expected.to be_a(ActiveRecord::Base)
        end
        context 'timestamps' do
          it 'has not' do
            expect(subject).to_not respond_to(:created_at)
            expect(subject).to_not respond_to(:updated_at)
          end
        end
        context 'saving' do
          subject do
            i = super()
            i.name = 'Bobo'
            i.save
            i
          end
          it 'does not error' do
            expect { subject }.to_not raise_error
          end
          it 'sets name' do
            expect(subject.name).to eq('Bobo')
          end
          it 'has no timestamps' do
            expect(subject).to_not respond_to(:created_at)
            expect(subject).to_not respond_to(:updated_at)
          end
        end
      end
    end
    context 'with block' do
      let(:table_name) { 'dogs' }
      let(:klass_basename) { 'my' }
      let(:columns) { ['name'] }
      let(:timestamps) { false }
      let(:connection_params) { AnonymousActiveRecord::DEFAULT_CONNECTION_PARAMS }
      subject {
        described_class.generate(
          table_name: table_name,
          klass_basename: klass_basename,
          columns: columns,
          timestamps: timestamps,
          connection_params: connection_params
        ) do
          def eat_pie
            'eating'
          end
          def flowery_name
            "🌸#{name}🌸"
          end
        end
      }
      it 'does not error' do
        expect { subject }.to_not raise_error
      end
      context 'instance' do
        subject { super().new(name: 'Marty McFly') }
        it 'can be instantiated' do
          is_expected.to be_a(ActiveRecord::Base)
        end
        context 'block' do
          it 'defines method' do
            expect(subject.eat_pie).to eq('eating')
          end
          it 'has access to class context' do
            expect(subject.flowery_name).to eq('🌸Marty McFly🌸')
          end
        end
        context 'timestamps' do
          it 'has not' do
            expect(subject).to_not respond_to(:created_at)
            expect(subject).to_not respond_to(:updated_at)
          end
        end
        context 'saving' do
          subject do
            i = super()
            i.name = 'Bobo'
            i.save
            i
          end
          it 'does not error' do
            expect { subject }.to_not raise_error
          end
          it 'sets name' do
            expect(subject.name).to eq('Bobo')
          end
          it 'has access to class context' do
            expect(subject.flowery_name).to eq('🌸Bobo🌸')
          end
          it 'has no timestamps' do
            expect(subject).to_not respond_to(:created_at)
            expect(subject).to_not respond_to(:updated_at)
          end
        end
      end
    end
    context 'testing a module' do
      let!(:has_balloon) do
        module HasBalloon
          def has_balloon?
            name == 'Spot' ? true : false # only Spot has a balloon
          end
        end
      end
      let(:ar_with_balloon) do
        described_class.generate(columns: ['name']) do
          include HasBalloon
          def flowery_name
            "#{b_f}#{name}#{b_f}"
          end
          def b_f
            has_balloon? ? '🎈' : '🌸'
          end
        end
      end
      it 'can test the module' do
        expect(ar_with_balloon.new(name: 'Spot').flowery_name).to eq('🎈Spot🎈')
        expect(ar_with_balloon.new(name: 'Not Spot').flowery_name).to eq('🌸Not Spot🌸')
      end
    end
  end

  describe '.factory' do
    context 'minimal params' do
      context 'returns array' do
        subject { described_class.factory() }
        it 'be an array' do
          is_expected.to be_a(Array)
        end
        it 'has length 0' do
          expect(subject.length).to eq(0)
        end
      end
    end
    context 'all params' do
      let!(:farm_animal) {
        module Zoo
          module Animal
          end
        end
      }
      let(:table_name) { 'dogs' }
      let(:klass_namespaces) { %w[Zoo Animal] }
      let(:klass_basename) { 'my' }
      let(:columns) { ['name'] }
      let(:timestamps) { true }
      let(:source_data) { [{ name: 'Gru Banksy' }, { name: 'Herlina Termalina' }] }
      let(:connection_params) { AnonymousActiveRecord::DEFAULT_CONNECTION_PARAMS }
      subject {
        described_class.factory(
          source_data: source_data,
          table_name: table_name,
          klass_namespaces: klass_namespaces,
          klass_basename: klass_basename,
          columns: columns,
          timestamps: timestamps,
          connection_params: connection_params
        )
      }
      context 'returns array' do
        it 'be an array' do
          is_expected.to be_a(Array)
        end
        it 'has length 2' do
          expect(subject.length).to eq(2)
        end
      end
      context 'sets attributes' do
        subject { super().map(&:name) }
        it 'be an array' do
          is_expected.to eq(['Gru Banksy', 'Herlina Termalina'])
        end
      end
    end
    context 'no timestamps' do
      let(:table_name) { 'dogs' }
      let(:klass_basename) { 'my' }
      let(:columns) { ['name'] }
      let(:timestamps) { false }
      let(:source_data) { [{ name: 'Gru Banksy' }, { name: 'Herlina Termalina' }] }
      let(:connection_params) { AnonymousActiveRecord::DEFAULT_CONNECTION_PARAMS }
      subject {
        described_class.factory(
          source_data: source_data,
          table_name: table_name,
          klass_basename: klass_basename,
          columns: columns,
          timestamps: timestamps,
          connection_params: connection_params
        )
      }
      context 'returns array' do
        it 'be an array' do
          is_expected.to be_a(Array)
        end
        it 'has length 2' do
          expect(subject.length).to eq(2)
        end
      end
      context 'does not have timestamps' do
        subject { super().map { |anon| anon.respond_to?(:created_at) } }
        it 'be an array' do
          is_expected.to eq([false, false])
        end
      end
    end
    context 'with block' do
      let(:table_name) { 'dogs' }
      let(:klass_basename) { 'my' }
      let(:columns) { ['name'] }
      let(:timestamps) { false }
      let(:source_data) { [{ name: 'Gru Banksy' }, { name: 'Herlina Termalina' }] }
      let(:connection_params) { AnonymousActiveRecord::DEFAULT_CONNECTION_PARAMS }
      subject {
        described_class.factory(
          source_data: source_data,
          table_name: table_name,
          klass_basename: klass_basename,
          columns: columns,
          timestamps: timestamps,
          connection_params: connection_params
        ) do
          def eat_pie
            'eating'
          end
          def flowery_name
            "🌸#{name}🌸"
          end
        end
      }
      context 'returns array' do
        it 'be an array' do
          is_expected.to be_a(Array)
        end
        it 'has length 2' do
          expect(subject.length).to eq(2)
        end
      end
      context 'defines method' do
        subject { super().map(&:eat_pie) }
        it 'defines method' do
          expect(subject).to eq(%w[eating eating])
        end
      end
      context 'sets attributes' do
        subject { super().map(&:flowery_name) }
        it 'be an array' do
          is_expected.to eq(['🌸Gru Banksy🌸', '🌸Herlina Termalina🌸'])
        end
      end
    end
  end
end
