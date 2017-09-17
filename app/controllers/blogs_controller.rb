# frozen_string_literal: true

class BlogsController < ApplicationController
  def new
    @blog = Blog.new
  end

  def confirm
    unless @blog.valid?
      render 'new'
      return
    end
    @blog.fetch
    render 'confirm'
  end

  def create
    

  end
end
