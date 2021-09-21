class SpellsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @spell = current_user.spells.build(spell_params)
    @spell.image.attach(params[:spell][:image])
    if @spell.save
      flash[:success] = "Spell created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def edit 
  end

  def update
    respond_to do |format|
      format.html
      format.js 
    end
    flash[:success] = "Spell updated"
    if request.referrer.nil? || request.referrer == spells_url
      redirect_to root_url
    else
      redirect_to request.referrer
    end
  end

  def destroy
    @spell.destroy
    flash[:success] = "Spell deleted"
    if request.referrer.nil? || request.referrer == spells_url
      redirect_to root_url
    else
      redirect_to request.referrer
    end
  end

  private 

  def spell_params
    params.require(:spell).permit(:content, :image)
  end

  def correct_user
    @spell = current_user.spells.find_by(id: params[:id])
    redirect_to root_url if @spell.nil?
  end
end
