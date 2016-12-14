require 'zentool/graph.rb'

describe Graph do
  describe '.wrap' do
    context "given 'qwertyuiop'" do
      it "returns 'qwertyuiop'" do
        expect(Graph.wrap('qwertyuiop')).to eql("qwertyuiop\n")
      end
    end
    context "given 'qwertyuiopasdfghjklzxcvbnm'" do
      it "returns 'qwertyuiopasdfghjklzxcvbnm\n'" do
        expect(Graph.wrap('qwertyuiopasdfghjklzxcvbnm')).to eql("qwertyuiopasdfghjklzxcvbnm\n")
      end
    end
    context "given 'hello world hi how are you'" do
      it "returns 'hello world hi how are you\n'" do
        expect(Graph.wrap('hello world hi how are you')).to eql("hello world hi how are you\n")
      end
    end
    context "given 'Hello this is a test string being used for photosythetic supercalifragilisticexpialadocius'" do
       it "returns 'Hello this is a test string\nbeing used for photosythetic\nsupercalifragilisticexpialadocius\n'" do
         expect(Graph.wrap('Hello this is a test string being used for photosythetic supercalifragilisticexpialadocius')).to eql("Hello this is a test string\nbeing used for photosythetic\nsupercalifragilisticexpialadocius\n")
       end
     end
  end

  describe '.extract_links' do
    context "given 'hello here is a link https://www.google.com that was the link'" do
      it 'returns [https://www.google.com]' do
        expect(Graph.extract_links('hello here is a link https://www.google.com that was the link')).to eql(['https://www.google.com'])
      end
    end
    context "given 'hello here https://www.reddit.com is a link https://www.google.com that was the link'" do
      it 'returns [https://www.reddit.com, https://www.google.com]' do
        expect(Graph.extract_links('hello here https://www.reddit.com is a link https://www.google.com that was the link')).to eql(['https://www.reddit.com','https://www.google.com'])
      end
    end
  end

  describe '.extract_IDs' do
    context "given 'https://www.google.com/1231296234/bla'" do
      it "returns '1231296234'" do
        expect(Graph.extract_IDs('https://www.google.com/1231296234/bla')).to eql(1231296234)
      end
    end
    context "given 'https://www.google.com/1292/bla'" do
      it "returns '1292'" do
        expect(Graph.extract_IDs('https://www.google.com/1292/bla')).to eql(1292)
      end
    end
  end
end