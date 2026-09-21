# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts' do
  def html_posts
    Capybara.string(response.body).all('article[data-post-slug]').map do |article|
      title_link = article.find('[data-post-title]')
      {
        'title' => title_link.text,
        'slug' => title_link[:href].delete_prefix('/posts/'),
        'tags' => article.all('[data-post-tag]').map(&:text),
      }
    end
  end

  def serialized(posts)
    posts.map do |post|
      {
        'title' => post.title,
        'slug' => post.slug,
        'tags' => post.tags,
      }
    end
  end

  def default_posts
    [
      {
        'title' => 'Building Reliable Ruby Services',
        'slug' => 'building-reliable-ruby-services',
        'tags' => %w[Ruby Architecture],
      },
      {
        'title' => 'Practical Rails Routing',
        'slug' => 'practical-rails-routing',
        'tags' => %w[Rails Ruby],
      },
      {
        'title' => 'Designing an Accessible Interface',
        'slug' => 'designing-an-accessible-interface',
        'tags' => %w[Accessibility HTML],
      },
    ]
  end

  def collection_response(format: :html, params: {})
    path = format == :json ? posts_path(format: :json) : posts_path
    get path, params: params

    {
      status: response.status,
      media_type: response.media_type,
      posts: format == :json ? response.parsed_body : html_posts,
    }
  end

  def expected_collection_response(posts, media_type: 'text/html')
    { status: 200, media_type: media_type, posts: posts }
  end

  def detail_response(slug)
    get post_path(slug)
    document = Capybara.string(response.body)

    {
      status: response.status,
      title: document.find('h1').text,
      tags: document.all('ul[aria-label="Tags"] li').map(&:text),
    }
  end

  def representations(params = {})
    %i[html json].map do |format|
      collection_response(format: format, params: params).fetch(:posts)
    end
  end

  describe 'GET /posts' do
    it 'lists every post once in publication and slug order with links and tags' do
      expect(collection_response).to eq(expected_collection_response(default_posts))
    end

    it 'filters by a whole tag without regard to case' do
      actual = collection_response(params: { tag: 'rUbY' })

      expect(actual).to eq(expected_collection_response(default_posts.first(2)))
    end

    it 'does not match part of a tag' do
      actual = collection_response(params: { tag: 'rub' })

      expect(actual).to eq(expected_collection_response([]))
    end

    it 'returns every post for missing, empty, or whitespace-only tags' do
      requests = [{}, { tag: '' }, { tag: '   ' }]
      expected = expected_collection_response(default_posts)

      expect(requests.map { |params| collection_response(params: params) }).to all(eq(expected))
    end

    it 'returns an empty successful collection for an unknown tag' do
      actual = collection_response(params: { tag: 'unknown' })

      expect(actual).to eq(expected_collection_response([]))
    end
  end

  describe 'GET /posts/:slug' do
    it 'displays the matching post title and tags' do
      expected = { status: 200, title: 'Building Reliable Ruby Services', tags: %w[Ruby Architecture] }

      expect(detail_response('building-reliable-ruby-services')).to eq(expected)
    end

    it 'returns not found for an unknown slug' do
      get post_path('unknown')

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /posts.json' do
    it 'returns every post as a top-level JSON array in the same order' do
      actual = collection_response(format: :json)
      expected = expected_collection_response(default_posts, media_type: 'application/json')

      expect(actual).to eq(expected)
    end

    it 'filters whole tags without regard to case' do
      actual = collection_response(format: :json, params: { tag: 'RuBy' })
      expected = expected_collection_response(default_posts.first(2), media_type: 'application/json')

      expect(actual).to eq(expected)
    end

    it 'does not match part of a tag' do
      actual = collection_response(format: :json, params: { tag: 'rub' })

      expect(actual).to eq(expected_collection_response([], media_type: 'application/json'))
    end

    it 'returns every post for missing, empty, or whitespace-only tags' do
      requests = [{}, { tag: '' }, { tag: '   ' }]
      expected = expected_collection_response(default_posts, media_type: 'application/json')

      expect(requests.map { |params| collection_response(format: :json, params: params) }).to all(eq(expected))
    end

    it 'returns an empty successful array for an unknown tag' do
      actual = collection_response(format: :json, params: { tag: 'unknown' })

      expect(actual).to eq(expected_collection_response([], media_type: 'application/json'))
    end
  end

  describe 'shared collection regression' do
    let(:source_posts) do
      [
        Post.new(
          title: 'Old Web Post',
          slug: 'old-web-post',
          tags: %w[Web],
          published_at: Time.utc(2024, 1, 1)
        ),
        Post.new(
          title: 'Zeta Ruby Post',
          slug: 'zeta-ruby-post',
          tags: %w[Ruby Testing],
          published_at: Time.utc(2025, 1, 1)
        ),
        Post.new(
          title: 'Alpha Ruby Post',
          slug: 'alpha-ruby-post',
          tags: %w[Architecture ruby],
          published_at: Time.utc(2025, 1, 1)
        ),
      ]
    end
    let(:ordered_posts) { [source_posts.fetch(2), source_posts.fetch(1), source_posts.fetch(0)] }
    let(:filtered_posts) { [source_posts.fetch(2), source_posts.fetch(1)] }
    let(:expected_representations) do
      [
        [serialized(ordered_posts), serialized(ordered_posts)],
        [serialized(filtered_posts), serialized(filtered_posts)],
      ]
    end

    before do
      stub_const('Post::COLLECTION', source_posts)
    end

    it 'keeps complete ordered HTML and JSON representations aligned when unfiltered and filtered' do
      actual = [representations, representations(tag: 'RUBY')]

      expect(actual).to eq(expected_representations)
    end
  end
end
