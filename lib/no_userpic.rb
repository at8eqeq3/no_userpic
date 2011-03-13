require 'rubygems'
require 'bundler/setup'
require 'rvg/rvg'
require 'digest'
include Magick
require 'prettyprint'

class NoUserpic
  @identicon_options = {}
	@blocks = 0
	@shapes = []
	@rotatable = []
	@square = []
	@im = nil
	@colors = []
	attr :size #= 0
	@blocksize = 0
	attr :quarter
	attr :half
	attr :diagonal
	attr :halfdiag
	attr :transparent
	@centers = []
	@shapes_mat = []
	attr :symmetric_num
	attr :rot_mat
	attr :invert_mat
	attr :rotations
	
	def initialize blocks = ''
	  @identicon_options = identicon_get_options
	  @blocks = blocks if blocks
	  @blocks = @blocks.to_i
	  @blocksize = 80
	  @size = @blocks * @blocksize
		@quarter = @blocksize / 4
		@half = @blocksize / 2
		@diagonal = Math.sqrt(@half * @half + @half * @half)
		@halfdiag = @diagonal / 2
		@shapes=[[[[90,  @half],     [135, @diagonal], [225, @diagonal], [270, @half]]],     # 0 rectangular half block
			       [[[45,  @diagonal], [135, @diagonal], [225, @diagonal], [315, @diagonal]]], # 1 full block
			       [[[45,  @diagonal], [135, @diagonal], [225, @diagonal]]],                   # 2 diagonal half block
			       [[[90,  @half],     [225, @diagonal], [315, @diagonal]]],                   # 3 triangle
        		 [[[0,   @half],     [90,  @half],     [180, @half],     [270, @half]]],     # 4 diamond
             [[[0,   @half],     [135, @diagonal], [270, @half],     [315, @diagonal]]], # 5 stretched diamond
			       [[[0,   @quarter],  [90,  @half],     [180, @quarter]],
			        [[0,   @quarter],  [315, @diagonal], [270, @half]],
			        [[270, @half],     [180, @quarter],  [225, @diagonal]]],                   # 6 triple triangle
			       [[[0,   @half],     [135, @diagonal], [270, @half]]],                       # 7 pointer
			       [[[45,  @halfdiag], [135, @halfdiag], [225, @halfdiag], [315, @halfdiag]]], # 8 center square
			       [[[180, @half],     [225, @diagonal], [0,   0]],
			        [[45,  @diagonal], [90,  @half],     [0,   0]]],                           # 9 double triangle diagonal
			       [[[90,  @half],     [135, @diagonal], [180, @half],     [0,   0]]],         # 10 diagonal square
			       [[[0,   @half],     [180, @half],     [270, @half]]],                       # 11 quarter triangle out
			       [[[315, @diagonal], [225, @diagonal], [0,   0]]],                           # 12 quarter triangle in
			       [[[90,  @half],     [180, @half],     [0,   0]]],                           # 13 eighth triangle in
			       [[[90,  @half],     [135, @diagonal], [180, @half]]],                       # 14 eighth triangle out
			       [[[90,  @half],     [135, @diagonal], [180, @half],     [0,   0]],
			        [[0,   @half],     [315, @diagonal], [270, @half],     [0,   0]]],         # 15 double corner square
    			   [[[315, @diagonal], [225, @diagonal], [0,   0]],
    			    [[45,  @diagonal], [135, @diagonal], [0,   0]]],                           # 16 double quarter triangle in
			       [[[90,  @half],     [135, @diagonal], [225, @diagonal]]],                   # 17 tall quarter triangle
    			   [[[90,  @half],     [135, @diagonal], [225, @diagonal]],
    			    [[45,  @diagonal], [90,  @half],     [270, @half]]],                       # 18 double tall quarter triangle
			       [[[90,  @half],     [135, @diagonal], [225, @diagonal]],
			        [[45,  @diagonal], [90,  @half],     [0,   0]]],                           # 19 tall quarter + eighth triangles
    			   [[[135, @diagonal], [270, @half],     [315, @diagonal]]],                   # 20 tipped over tall triangle
			       [[[180, @half],     [225, @diagonal], [0,   0]],
			        [[45,  @diagonal], [90,  @half],     [0,   0]],
			        [[0,   @half],     [0,   0],         [270, @half]]],                       # 21 triple triangle diagonal
 			       [[[0,   @quarter],  [315, @diagonal], [270, @half]],
 			        [[270, @half],     [180, @quarter],  [225, @diagonal]]],                   # 22 double triangle flat
			       [[[0,   @quarter],  [45,  @diagonal], [315, @diagonal]],
			        [[180, @quarter],  [135, @diagonal], [225, @diagonal]]],                   # 23 opposite 8th triangles
			       [[[0,   @quarter],  [45,  @diagonal], [315, @diagonal]],
			        [[180, @quarter],  [135, @diagonal], [225, @diagonal]],
			        [[180, @quarter],  [90,  @half],     [0,   @quarter],  [270, @half]]],     # 24 opposite 8th triangles + diamond
			       [[[0,   @quarter],  [90,  @quarter],  [180, @quarter],  [270, @quarter]]],  # 25 small diamond
 			       [[[0,   @quarter],  [45,  @diagonal], [315, @diagonal]],
 			        [[180, @quarter],  [135, @diagonal], [225, @diagonal]],
 			        [[270, @quarter],  [225, @diagonal], [315, @diagonal]],
 			        [[90,  @quarter],  [135, @diagonal], [45,  @diagonal]]],                   # 26 4 opposite 8th triangles
			       [[[315, @diagonal], [225, @diagonal], [0,   0]],
			        [[0,   @half],     [90,  @half],     [180, @half]]],                       # 27 double quarter triangle parallel
		      	 [[[135, @diagonal], [270, @half],     [315, @diagonal]],
		      	  [[225, @diagonal], [90,  @half],     [45,  @diagonal]]],                   # 28 double overlapping tipped over tall triangle
			       [[[90,  @half],     [135, @diagonal], [225, @diagonal]],
			        [[315, @diagonal], [45,  @diagonal], [270, @half]]],                       # 29 opposite double tall quarter triangle
    			   [[[0,   @quarter],  [45,  @diagonal], [315, @diagonal]],
    			    [[180, @quarter],  [135, @diagonal], [225, @diagonal]],
    			    [[270, @quarter],  [225, @diagonal], [315, @diagonal]],
    			    [[90,  @quarter],  [135, @diagonal], [45,  @diagonal]],
    			    [[0,   @quarter],  [90,  @quarter],  [180, @quarter],  [270, @quarter]]],  # 30 4 opposite 8th triangles+tiny diamond
			       [[[0,   @half],     [90,  @half],     [180, @half],     [270, @half],     [270, @quarter],  [180, @quarter],  [90,  @quarter],  [0,   @quarter]]], #31 diamond C
			       [[[0,   @quarter],  [90,  @half],     [180, @quarter],  [270, @half]]],     # 32 narrow diamond
			       [[[180, @half],     [225, @diagonal], [0,   0]],
			        [[45,  @diagonal], [90,  @half],     [0,   0]],
			        [[0,   @half],     [0,   0],         [270, @half]],
			        [[90,  @half],     [135, @diagonal], [180, @half]]],                       # 33 quadruple triangle diagonal
			       [[[0,   @half],     [90,  @half],     [180, @half],     [270, @half],     [0,   @half],     [0,   @quarter],  [270, @quarter],  [180, @quarter],  [90,  @quarter],  [0,   @quarter]]], #34 diamond donut
			       [[[90,  @half],     [45,  @diagonal], [0,   @quarter]],
			        [[0,   @half],     [315, @diagonal], [270, @quarter]],
			        [[270, @half],     [225, @diagonal], [180, @quarter]]],                    # 35 triple turning triangle
			       [[[90,  @half],     [45,  @diagonal], [0,   @quarter]],
			        [[0,   @half],     [315, @diagonal], [270, @quarter]]],                    # 36 double turning triangle
			       [[[90,  @half],     [45,  @diagonal], [0,   @quarter]],
			        [[270, @half],     [225, @diagonal], [180, @quarter]]],                    # 37 diagonal opposite inward double triangle
			       [[[90,  @half],     [225, @diagonal], [0,   0],         [315, @diagonal]]], # 38 star fleet
			       [[[90,  @half],     [225, @diagonal], [0,   0],         [315, @halfdiag], [225, @halfdiag], [225, @diagonal], [315, @diagonal]]], # 39 hollow half triangle
			       [[[90,  @half],     [135, @diagonal], [180, @half]],
			        [[270, @half],     [315, @diagonal], [0,   @half]]],                       # 40 double eighth triangle out
			       [[[90,  @half],     [135, @diagonal], [180, @half],     [180, @quarter]],
			        [[270, @half],     [315, @diagonal], [0,   @half],     [0,   @quarter]]],  # 42 double slanted square
			       [[[0,   @half],     [45,  @halfdiag], [0,   0],         [315, @halfdiag]],
			        [[180, @half],     [135, @halfdiag], [0,   0],         [225, @halfdiag]]], # 43 double diamond
			       [[[0,   @half],     [45,  @diagonal], [0,   0],         [315, @halfdiag]],
			        [[180, @half],     [135, @halfdiag], [0,   0],         [225, @diagonal]]], # 44 double pointer
		]
		@rotatable = [1, 4, 8, 25, 26, 30, 34]
		@square = @shapes[1][0]	
		@symmetric_num = (@blocks.to_i * @blocks.to_i / 4).ceil
		@centers = [] unless @centers
		for i in 0..@blocks do
		  @centers[i] = [] unless @centers[i]
			for j in 0..@blocks do
				@centers[i][j] = [@half + @blocksize * j, @half + @blocksize * i]
        @shapes_mat = [] unless @shapes_mat
				@shapes_mat[xy2symmetric(i, j)] = 1
				@rot_mat = [] unless @rot_mat
				@rot_mat[xy2symmetric(i, j)]    = 0
				@invert_mat = [] unless @invert_mat
				@invert_mat[xy2symmetric(i, j)] = 0
				if ((((@blocks - 1) / 2 - i).floor >=0) and (((@blocks - 1) / 2 - j).floor >= 0) and ((j >= i) or (@blocks % 2 == 0)))
					inversei = @blocks - 1 - i
					inversej = @blocks - 1 - j
					symmetrics = [[i, j], [inversej, i], [inversei, inversej], [j, inversei]]
					fill = [0, 270, 180, 90]
					for k in 0..(symmetrics.count - 1) do
					  @rotations = [] unless @rotations
					  @rotations[symmetrics[k][0]] = [] unless @rotations[symmetrics[k][0]]
						@rotations[symmetrics[k][0]][symmetrics[k][1]] = fill[k];
					end
				end
			end
		end
	end
	
	def xy2symmetric x, y
		index = [((@blocks - 1) / 2 - x).abs.floor, ((@blocks - 1) / 2 - y).abs.floor]
		index.sort!
		index[1] *= (@blocks / 2).ceil
		index.reduce(:+)
	end
	
	def deg2rad deg
	  deg * Math::PI / 180
	end
	
	def identicon_calc_x_y array, centers, rotation = 0
		output  = []
		centerx = centers[0]
		centery = centers[1]
		array.each do |e|
			y = (centery + Math.sin(deg2rad(e[0] + rotation)) * e[1]).round
			x = (centerx + Math.cos(deg2rad(e[0] + rotation)) * e[1]).round
			output << x << y
		end
		return output
	end
	
	def identicon_draw_shape x, y, img
		index    = xy2symmetric x, y
		shape    = @shapes[@shapes_mat[index]]
		invert   = @invert_mat[index]
		rotation = @rot_mat[index]
		centers  = @centers[x][y]
		invert2  = (invert - 1).abs
		points   = identicon_calc_x_y @square, centers, 0
		img.polygon(points).styles(:fill => @colors[invert2]) #what is colors?
		shape.each do |subshape|
		  p @rotations
	    #puts @rotations[x][y]
			points = identicon_calc_x_y subshape, centers, (rotation + @rotations[x][y].to_i)
			img.polygon(points).styles(:fill => @colors[invert])
		end
	end
	
	def identicon_set_randomness seed = ""
		srand seed.to_i
		@rot_mat.each_index do |i|
			@rot_mat[i] = rand(3) * 90
			@invert_mat[i] = rand(1)
			#&$this->blocks%2
			@shapes_mat[i] = (i == 0 ? @rotatable[rand(@rotatable.length)] : rand(@shapes.length))
		end
		forecolors = [rand_between(@identicon_options['forer'][0], @identicon_options['forer'][1]), rand_between(@identicon_options['foreg'][0], @identicon_options['foreg'][1]), rand_between(@identicon_options['foreb'][0], @identicon_options['foreb'][1])]
		p forecolors
		@colors[1] = "#" + forecolors[0].to_s(16).rjust(2, "0") + forecolors[1].to_s(16).rjust(2, "0") + forecolors[2].to_s(16).rjust(2, "0")
		# don't know, how to implement this :(
		#if (array_sum($this->identicon_options['backr']) + array_sum($this->identicon_options['backg']) + array_sum($this->identicon_options['backb'])==0) {
		#	$this->colors[0]=imagecolorallocatealpha($this->im,0,0,0,127);
		#	$this->transparent=true;
		#	imagealphablending ($this->im,false);
		#	imagesavealpha($this->im,true);
		#} else {
			backcolors = [rand_between(@identicon_options['backr'][0], @identicon_options['backr'][1]), rand_between(@identicon_options['backg'][0], @identicon_options['backg'][1]), rand_between(@identicon_options['backb'][0], @identicon_options['backb'][1])]
			@colors[0] = "#" + backcolors[0].to_s(16).rjust(2, "0") + backcolors[1].to_s(16).rjust(2, "0") + backcolors[2].to_s(16).rjust(2, "0")
		#}
		if @identicon_options['grey']
			@colors[1] = "#" + forecolors[0].to_s(16).rjust(2, "0") + forecolors[1].to_s(16).rjust(2, "0") + forecolors[2].to_s(16).rjust(2, "0")
			#if(!$this->transparent) $this->colors[0]=imagecolorallocate($this->im, $backcolors[0],$backcolors[0],$backcolors[0]);
			@colors[0] = "#" + backcolors[0].to_s(16).rjust(2, "0") + backcolors[1].to_s(16).rjust(2, "0") + backcolors[2].to_s(16).rjust(2, "0")
		end
		return true
	end
	
	def identicon_build seed = '', alt_img_text = '', img = true, outsize = nil, write = true, random = true, displaysize = nil
		# make an identicon and return the filepath or if write=false return picture directly
		#if (function_exists("gd_info")){
			# init random seed
			id = random ? Digest::SHA1.hexdigest(seed.to_s)[0, 10] : seed
			filename = Digest::SHA1.hexdigest(id + get_option('admin_email')[0, 5])[0, 15] + ".png"
			outsize = @identicon_options['size'] unless outsize
			displaysize = outsize unless displaysize
			unless File.exist?("./" + filename)
				@im = RVG.new(size, size) do |img|
				  @colors = ["#ffffff"]
				  if random
				    identicon_set_randomness id
				  else
				    
				    @colors = ["#ffffff", "#000000"]
				    @transparent = false
				  end
				  p "="*40
				  p @colors
				  img.background_fill = @colors[0]
				  for i in 0..(@blocks - 1) do
					  for j in 0..(@blocks - 1) do
					    identicon_draw_shape i, j, img
					  end
				  end
				end
				
				#$out = @imagecreatetruecolor($outsize,$outsize);
				#imagesavealpha($out,true);
				#imagealphablending($out,false);
				#imagecopyresampled($out,$this->im,0,0,0,0,$outsize,$outsize,$this->size,$this->size);
				#imagedestroy($this->im);
				#if ($write){
				#@im.width  = outsize
				#@im.height = outsize
				@im.draw.write("./" + filename)
						#$wrote=imagepng($out,WP_IDENTICON_DIR_INTERNAL.$filename); # rvg.draw.write('duck.gif')
						#if(!$wrote) return false; #something went wrong but don't want to mess up blog layout
				#}else{
				#	header ("Content-type: image/png");
				#	imagepng($out);
				#}
				@im = nil
			end
			#$filename=get_option('siteurl').WP_IDENTICON_DIR.$filename;
			#if($this->identicon_options['gravatar']&&$gravataron)
      #  $filename = "http://www.gravatar.com/avatar.php?gravatar_id=".md5($seed)."&amp;size=$outsize&amp;default=$filename";
			#if ($img){
			#	$filename='<img class="identicon" src="'.$filename.'" alt="'.str_replace('"',"'",$altImgText).' Identicon Icon" height="'.$displaysize.'" width="'.$displaysize.'" />';
			#}
			return filename
		#} else { //php GD image manipulation is required
		#	return false; //php GD image isn't installed but don't want to mess up blog layout
		#}
	end

	#function identicon_display_parts(){
	#	$this->identicon(1);
	#	for ($i=0;$i<count($this->shapes);$i++){
	#		$this->shapes_mat=array($i);
	#		$this->invert_mat=array(1);
	#		$output.=$this->identicon_build($seed='example'.$i,$altImgText='',$img=true,$outsize=30,$write=true,$random=false);
	#		$counter++;
	#	}
	#	$this->identicon();
	#return $output;
	#}
	
	def identicon_get_options
	  identicon_array = get_option('identicon')
	  if (!identicon_array.has_key?('size')|!identicon_array.has_key?('backb'))
		  #Set Default Values Here
		  default_array = {'size'     => 35,
		                   'backr'    => [255, 255],
		                   'backg'    => [255, 255],
		                   'backb'    => [255, 255],
		                   'forer'    => [1,   255],
		                   'foreg'    => [1,   255],
		                   'foreb'    => [1,   255],
		                   'squares'  => 4,
		                   'autoadd'  => 1,
		                   'gravatar' => 0,
		                   'grey'     => 0}
		  #add_option('identicon',$default_array,'Options used by Identicon',false);
		  identicon_array = default_array;
	  end
	  return identicon_array
  end
	
	#stub
	def get_option o
	  case o
	    when 'identicon': return Hash.new
	    else return 'hello'
	  end
	end
	
	def rand_between x, y
	  return x if y - x == 0
	  return rand(y - x) + x
	end
	
end
