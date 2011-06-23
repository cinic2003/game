class SwfsController < ApplicationController
  
  def download_swf
    @swf = Swf.find params[:id]
    Resque.enqueue(DownFlash, @swf.id)
    redirect_to @swf, :notice => "Download this flash"
  end


  # GET /swfs
  # GET /swfs.xml
  def index
    @swfs = Swf.all.paginate :per_page => 20, :page => params[:page], :limit => 50

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @swfs }
    end
  end

  # GET /swfs/1
  # GET /swfs/1.xml
  def show
    @swf = Swf.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @swf }
    end
  end

  # GET /swfs/new
  # GET /swfs/new.xml
  def new
    @swf = Swf.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @swf }
    end
  end

  # GET /swfs/1/edit
  def edit
    @swf = Swf.find(params[:id])
  end

  # POST /swfs
  # POST /swfs.xml
  def create
    @swf = Swf.new(params[:swf])

    respond_to do |format|
      if @swf.save
        format.html { redirect_to(@swf, :notice => 'Swf was successfully created.') }
        format.xml  { render :xml => @swf, :status => :created, :location => @swf }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @swf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /swfs/1
  # PUT /swfs/1.xml
  def update
    @swf = Swf.find(params[:id])

    respond_to do |format|
      if @swf.update_attributes(params[:swf])
        format.html { redirect_to(@swf, :notice => 'Swf was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @swf.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /swfs/1
  # DELETE /swfs/1.xml
  def destroy
    @swf = Swf.find(params[:id])
    @swf.destroy

    respond_to do |format|
      format.html { redirect_to(swfs_url) }
      format.xml  { head :ok }
    end
  end
end
