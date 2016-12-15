# Graph class for pull_articles.rb

class Graph
  def initialize(articles, sections, categories)
    @id_title_map = {}
    @article_link_map = {}
    @articles, @sections, @categories = articles, sections, categories
  end

  def generate
    create_id_title_relationship
    article_link_map
    create_id_title_relationship
    graph_settings
    graph_nodes
    graph_edges
    @g.output(png: 'article_relationships.png')
  end

  def self.wrap(s, width = 15)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end

  def create_id_title_relationship
    @articles.each do |article|
      @id_title_map[article['id']] = article['title']
    end
  end

  def self.extract_links(string)
    [URI.extract(string, /http(s)?/)].flatten
  end

  def self.extract_IDs(string)
    string.split(//).map { |x| x[/\d+/] }.compact.join('').to_i
  end

  def article_link_map
    @articles.each do |article|
      unless (@categories[@sections[article['section_id']]['category_id']]['name'] == 'Announcements') || (article['body'].class != String)
        referenced_links = Graph.extract_links(article['body'])
        referenced_articles = []
        unless referenced_links.empty?
          referenced_links.each do |link|
            id = Graph.extract_IDs(link)
            title = @id_title_map[id]
            unless (id.class == NilClass) || (title.class == NilClass) || (id.to_s.size != 9)
              referenced_articles << Graph.wrap("#{title}\n#{id}")
            end
          end
          @article_link_map[article['id']] = referenced_articles
        end
      end
    end
  end

  def graph_settings
    $LOAD_PATH.unshift('../lib')
    @g = GraphViz.new('G')

    @g.node[:color] = '#222222'
    @g.node[:style] = 'filled'
    @g.node[:shape] = 'box'
    @g.node[:penwidth] = '1'
    @g.node[:fontname] = 'Helvetica'
    @g.node[:fillcolor] = '#eeeeee'
    @g.node[:fontcolor] = '#333333'
    @g.node[:margin] = '0.05'
    @g.node[:fontsize] = '12'
    @g.edge[:color] = '#666666'
    @g.edge[:weight] = '1'
    @g.edge[:fontsize] = '10'
    @g.edge[:fontcolor] = '#444444'
    @g.edge[:fontname] = 'Helvetica'
    @g.edge[:dir] = 'forward'
    @g.edge[:arrowsize] = '1'
    @g.edge[:arrowhead] = 'vee'
  end

  def graph_nodes
    nodes = []
    @article_link_map.each do |id, _referenced_articles|
      nodes << Graph.wrap("#{@id_title_map[id]}\n#{id}")
    end
    @g.add_nodes(nodes)
  end

  def graph_edges
    @article_link_map.each do |id, referenced_articles|
      @g.add_edges(Graph.wrap("#{@id_title_map[id]}\n#{id}"), referenced_articles.map(&:to_s))
    end
  end
end
