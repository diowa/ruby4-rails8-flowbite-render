# frozen_string_literal: true

class PostsController < ApplicationController
  def index
    @posts = Post.all(tag: params[:tag])

    respond_to do |format|
      format.html
      format.json { render json: @posts }
    end
  end

  def show
    @post = Post.find_by(slug: params[:slug])
    head :not_found unless @post
  end
end
