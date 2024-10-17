class Api::V1::ArticlesController < Api::V1::BaseController
  def show
    article = Article.published.find(params[:id])
    render json: article
  end
end
