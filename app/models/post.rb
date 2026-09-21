# frozen_string_literal: true

class Post
  attr_reader :title, :slug, :tags, :published_at

  def initialize(title:, slug:, tags:, published_at:)
    @title = title
    @slug = slug
    @tags = tags
    @published_at = published_at
  end

  COLLECTION = [
    new(
      title: 'Building Reliable Ruby Services',
      slug: 'building-reliable-ruby-services',
      tags: %w[Ruby Architecture],
      published_at: Time.utc(2025, 2, 14, 9)
    ),
    new(
      title: 'Practical Rails Routing',
      slug: 'practical-rails-routing',
      tags: %w[Rails Ruby],
      published_at: Time.utc(2025, 2, 14, 9)
    ),
    new(
      title: 'Designing an Accessible Interface',
      slug: 'designing-an-accessible-interface',
      tags: %w[Accessibility HTML],
      published_at: Time.utc(2025, 1, 20, 12)
    ),
  ].freeze

  def self.all(tag: nil)
    order(filter_by_tag(tag))
  end

  def self.find_by(slug:)
    COLLECTION.find { |post| post.slug == slug }
  end

  def as_json(_options = nil)
    {
      title: title,
      slug: slug,
      tags: tags,
    }
  end

  def self.filter_by_tag(tag)
    normalized_tag = tag.to_s.strip
    return COLLECTION if normalized_tag.empty?

    COLLECTION.select do |post|
      post.tags.any? { |post_tag| post_tag.casecmp?(normalized_tag) }
    end
  end
  private_class_method :filter_by_tag

  def self.order(posts)
    posts.sort do |first, second|
      published_at_order = second.published_at <=> first.published_at
      published_at_order.zero? ? first.slug <=> second.slug : published_at_order
    end
  end
  private_class_method :order
end
