# Article Helper class, called from zentool.rb to do all the work with articles

class ArticleHelper
  def initialize
  end

  def run
    fetch_content
    generate_summary
    generate_local_directory
    generate_problem_articles
    create_graph
  end

  private

  def fetch_content
    puts ' Envision Zendesk Articles'
    puts '---------------------------'

    puts '-> Retrieving Categories'
    @zendesk = ZendeskArticle.new
    @categories = Hash[@zendesk.categories.collect { |s| [s['id'], s] }]

    puts "\n-> Retrieving Sections"
    @zendesk = ZendeskArticle.new
    @sections = Hash[@zendesk.sections.collect { |s| [s['id'], s] }]

    puts "\n-> Retrieving Articles\n"
    @zendesk = ZendeskArticle.new
    @articles = @zendesk.articles
    puts
  end

  def generate_summary
    puts '-> Generating article summary file: all_articles.csv'
    CSV.open('all_articles.csv', 'wb') do |csv|
      csv << @zendesk.export_columns
      @articles.each do |hash|
        row = []
        @zendesk.export_columns.each do |column|
          case column
          when 'category'
            row << @categories[@sections[hash['section_id']]['category_id']]['name']
          when 'section'
            row << @sections[hash['section_id']]['name']
          when 'word_count'
            row << Nokogiri::HTML.parse(hash['body']).text.squish.split(' ').size
          else
            row << hash[column]
          end
        end
        csv << row
      end
    end
  end

  def generate_local_directory
    @directory = "./articles-#{DateTime.now}"

    search_message = 'not yet available'
    @found_articles = []

    puts "-> Generating individual article files in #{@directory}"
    Dir.mkdir(@directory)
    @articles.each do |article|
      filename = "#{article['name']}.html".tr(' ', '-').tr('/', ':')
      filepath = "#{@directory}/#{filename}"
      if article['body']
        File.open(filepath, 'w') { |f| f.write(article['body']) }
        @found_articles << filename if article['body'].include? search_message
      end
    end
  end

  def generate_problem_articles
    puts "-> Generating summary of problem articles in #{@directory}"
    File.open('problem_articles.csv', 'w') do |file|
      file.puts 'article_filename'
      @found_articles.each do |article_filename|
        file.puts(article_filename)
        puts '   - ' + article_filename
      end
    end
  end

  def create_graph
    graph = Graph.new(@articles, @sections, @categories)
    graph.generate
  end
end
