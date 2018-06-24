class PiecesController < ApplicationController

  def show
      @local_game_id = Piece.find_by_id(params[:id]).game_id
      @local_game = Game.find_by_id(@local_game_id)
      @local_pieces = @local_game.pieces
     
      @current_piece = Piece.find_by_id(params[:id])
  end

  def promote

  end

  def update
      puts "............."
      puts params


      @current_piece = Piece.find_by_id(piece_params[:id])

      @local_game_id = @current_piece.game_id
      @local_game = Game.find(@local_game_id)
      @local_pieces = @local_game.pieces

      @target_x = piece_params[:position_x].to_i
      @target_y = piece_params[:position_y].to_i
      @promo = piece_params[:promo]
      @target = @local_game.pieces.where(position_x: @target_x, position_y: @target_y).first
      @old_x = @current_piece.position_x
      @old_y = @current_piece.position_y
      

      if @current_piece.valid_move?(@target_x, @target_y)
        @current_piece.move_to!(@target_x, @target_y, @promo)
        king = @local_game.pieces.where(type: "King", color: @current_piece.color)[0]
        if king.is_in_check? == true
          @current_piece.move_to!(@old_x, @old_y)
          if @target != nil
            @revert = Piece.find_by(id: @target.id)
            @revert.update_attributes!(position_x: @target_x, position_y: @target_y)
          end
          @local_game.next_player(@local_game.next_player_id)
        end
        @local_game.next_player(@local_game.next_player_id)
      else
        flash[:notice] = "That was not a valid move"  
      end
      @local_game.reload
      sleep(6)
      redirect_to game_path(@local_game_id) 
  end

private
  def piece_params
      params.require(:piece).permit(:id, :position_x, :position_y, :promo)
  end
end
