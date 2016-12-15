require 'zentool/graph.rb'
require 'zentool/article_helper.rb'

class Graph
  attr_accessor :articles, :sections, :categories
end

describe Graph do
  describe 'initialization' do
    context 'with valid data' do
      it 'populates attributes' do
        test_articles = {a: 1}
        test_sections = {s: 58}
        test_categories = {c: 3.14}
        graph = Graph.new(test_articles,test_sections,test_categories)
        expect(graph.articles).to eql(test_articles)
        expect(graph.sections).to eql(test_sections)
        expect(graph.categories).to eql(test_categories)
      end
    end
  end

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
      it "returns 'hello world hi\nhow are you\n'" do
        expect(Graph.wrap('hello world hi how are you')).to eql("hello world hi\nhow are you\n")
      end
    end
    context "given 'Hello this is a test string being used for photosythetic supercalifragilisticexpialadocius'" do
       it "returns 'Hello this is a\ntest string being used for\nphotosythetic\nsupercalifragilisticexpialadocius\n'" do
         expect(Graph.wrap("Hello this is a test string being used for photosythetic supercalifragilisticexpialadocius")).to eql("Hello this is a\ntest string\nbeing used for\nphotosythetic\nsupercalifragilisticexpialadocius\n")
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

  describe '.create_id_title_map' do
    context 'given an array of hashes of articles w/ id + titles' do
      it 'creates a hash article id: titles' do
        articles_input = [{'id' => 10, 'title' => 'ten'}, {'id' => 74365, 'title' => 'Green eggs and ham'}, {'id' => 333, 'title' => 'cat mat bat'}]
        article_output = {'10' => 'ten', '74365' => 'Green eggs and ham', '333' => 'cat mat bat'}
        expect(Graph.create_id_title_map(articles_input)).to eql(article_output)
      end
    end
  end
end
