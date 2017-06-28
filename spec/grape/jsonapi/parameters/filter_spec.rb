describe Grape::Jsonapi::Parameters::Filter do
  let(:valid_keys) { %i[aaa bbb ccc] }

  context '#allow' do
    subject { described_class.allow(valid_keys) }

    it 'makes a filter class' do
      expect(subject).to respond_to(:valid_keys)
      expect(subject.valid_keys).to eq valid_keys
    end
  end

  context '.parse' do
    subject { described_class.allow(valid_keys).parse(json) }

    context 'when json is invalid' do
      context 'unparseable error' do
        let(:json) { '{ not valid json' }

        it 'throws a json exception' do
          expect { subject }.to raise_error(JSON::ParserError)
        end
      end

      context 'bad values' do
        let(:json) { JSON.unparse(aaa: {}) }

        it 'throws an exception' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            '["Invalid type for aaa"]'
          )
        end
      end

      context 'bad values in an array' do
        let(:json) { JSON.unparse(aaa: [{}, 1, 2]) }

        it 'throws an exception' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            '["Invalid type in array for aaa"]'
          )
        end
      end

      context 'one forbidden key' do
        let(:json) { JSON.unparse(aaa: 123, zzz: 123) }

        it 'throws an invalid key exception' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            '["Invalid key: zzz"]'
          )
        end
      end
      context 'multi forbidden key' do
        let(:json) { JSON.unparse(yyy: 123, zzz: 123) }

        it 'raises an exception with and array of errors' do
          expect { subject }.to raise_error(
            Grape::Jsonapi::Exceptions::FilterError,
            '["Invalid key: yyy","Invalid key: zzz"]'
          )
        end
      end
    end
  end
end
