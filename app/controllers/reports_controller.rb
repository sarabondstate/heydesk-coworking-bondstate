class ReportsController < ApplicationController
  

  def stables_report
    limit = 20
    @stables = Stable.all.order(:name)
    respond_to do |format|
      format.html{
        @stables = @stables.paginate(page: params[:page],per_page: limit)
      }
      format.js { 
       
        render :layout => false 
      }
      format.csv { 
        send_data Stable.to_csv(@stables), :filename => "Stables Report #{Time.now.strftime("%m/%d/%Y")}.csv" 
      }
    end

  end

  def users_report
    limit = 10
    @users = User.all.order(:name)
    respond_to do |format|
      format.html{
        @users = @users.paginate(page: params[:page],per_page: limit)
      }
      format.js { 
       
        render :layout => false 
      }
      format.csv { 
        send_data User.to_csv(@users), :filename => "Users Report #{Time.now.strftime("%m/%d/%Y")}.csv" 
      }
    end

  end

end
