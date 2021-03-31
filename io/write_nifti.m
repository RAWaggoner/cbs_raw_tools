function hdr = write_nifti(niftiname,data,hdr)

%_
% Usage: write_nifti(niftiname,data,hdr)
%
%
% niftiname - name of nifti file to write
% data - data array, should be int16 or float
% hdr - nifti header - if absent, a minimal header will be created
%
% R. Allen Waggoner, RIKEN-CBS
% version = 20120.10.24
%
%   (c) RIKEN 2019, 2020. All rights reserved. 
%

error = 1;
if(nargin < 2)
  fprintf('error = write_nifti(niftiname,data,hdr)\n');
  return;
end

[path base ext] = fileparts(niftiname);

%
% Fill in missing parts of header
%


hdr.dim = ones(1,8);
hdr.dim(1) = 4;
hdr.dim(2) = size(data,1);
hdr.dim(3) = size(data,2);
hdr.dim(4) = size(data,3);
hdr.dim(5) = size(data,4);


if ~isfield(hdr,'vox_offset') hdr.vox_offset = 352; end

if ~isfield(hdr,'sizeof_hdr') hdr.sizeof_hdr = 348; end
if strcmp(ext,'.nii') && (hdr.vox_offset == 0) hdr.vox_offset = hdr.sizeof_hdr + 4; end

if ~isfield(hdr,'data_type') hdr.data_type = blanks(10); end
hdr.data_type = [hdr.data_type(:)' repmat(' ',[1 10])];
hdr.data_type = hdr.data_type(1:10);

if ~isfield(hdr,'db_name') hdr.db_name = blanks(18); end
hdr.db_name = [hdr.db_name(:)' repmat(' ',[1 18])];
hdr.db_name = hdr.db_name(1:18);

if ~isfield(hdr,'extents') hdr.extents = 0; end
if ~isfield(hdr,'session_error') hdr.session_error = 0; end


if ~isfield(hdr,'pixdim') 
	hdr.pixdim = zeros(8,1); 
	hdr.pixdim(1) = 1;
	hdr.pixdim(2) = 192.0/hdr.dim(2);
	hdr.pixdim(3) = 192.0/hdr.dim(3);
	hdr.pixdim(4) = 120.0/hdr.dim(4);
	hdr.pixdim(5) = 2000.0;
end
hdr.pixdim = [hdr.pixdim(:)' repmat(0,[1 8])];
hdr.pixdim = hdr.pixdim(1:8);

if ~isfield(hdr,'regular') hdr.regular = 'r'; end
if ~isfield(hdr,'dim_info') hdr.dim_info = uint8(48); end
if ~isfield(hdr,'slice_code') hdr.slice_code = uint8(5); end
if ~isfield(hdr,'xyzt_units') hdr.xyzt_units = uint8(18); end
if ~isfield(hdr,'vox_offset') hdr.vox_offset = 352; end

if ~isfield(hdr,'intent_p1') hdr.intent_p1 = 0; end
if ~isfield(hdr,'intent_p2') hdr.intent_p2 = 0; end
if ~isfield(hdr,'intent_p3') hdr.intent_p3 = 0; end
if ~isfield(hdr,'intent_code') hdr.intent_code = 0; end

if ~isfield(hdr,'slice_start') hdr.slice_start = 0; end
if ~isfield(hdr,'slice_end') hdr.slice_end = hdr.dim(4) - hdr.slice_start; end

if ~isfield(hdr,'scl_slope') hdr.scl_slope = 1; end
if ~isfield(hdr,'scl_inter') hdr.scl_inter = 0; end
if ~isfield(hdr,'cal_max') hdr.cal_max = 0; end
if ~isfield(hdr,'cal_min') hdr.cal_min = 0; end
if ~isfield(hdr,'slice_duration') hdr.slice_duration = 0; end
if ~isfield(hdr,'toffset') hdr.toffset = 0; end


if ~isfield(hdr,'glmax') hdr.glmax = 0; end
if ~isfield(hdr,'glmin') hdr.glmin = 0; end

if ~isfield(hdr,'descrip') hdr.descrip = blanks(80); end
hdr.descrip = [hdr.descrip(:)' repmat(' ',[1 80])];
hdr.descrip = hdr.descrip(1:80);

if ~isfield(hdr,'aux_file') hdr.aux_file = blanks(24); end
hdr.aux_file = [hdr.aux_file(:)' repmat(' ',[1 24])];
hdr.aux_file = hdr.aux_file(1:24);

if ~isfield(hdr,'qform_code') hdr.qform_code = 0; end
if ~isfield(hdr,'sform_code') hdr.sform_code = 0; end

if ~isfield(hdr,'quatern_b') hdr.quatern_b = 0; end
if ~isfield(hdr,'quatern_c') hdr.quatern_c = 0; end
if ~isfield(hdr,'quatern_d') hdr.quatern_d = 0; end
if ~isfield(hdr,'quatern_x') hdr.quatern_x = 0; end
if ~isfield(hdr,'quatern_y') hdr.quatern_y = 0; end
if ~isfield(hdr,'quatern_z') hdr.quatern_z = 0; end
if ~isfield(hdr,'srow_x') hdr.srow_x = zeros(1,4); end
if ~isfield(hdr,'srow_y') hdr.srow_y = zeros(1,4); end
if ~isfield(hdr,'srow_z') hdr.srow_z = zeros(1,4); end

if ~isfield(hdr,'intent_name') hdr.intent_name = blanks(16); end
hdr.intent_name = [hdr.intent_name(:)' repmat(' ',[1 16])];
hdr.intent_name = hdr.intent_name(1:16);

% if ~isfield(hdr,'magic') hdr.magic = char([110,43,49,0]); end
hdr.magic = char([110,43,49,0]);


if isfloat(data) 
 % 'float' 
  hdr.datatype=16;
  hdr.bitpix=32;
else
  hdr.datatype=4;
  hdr.bitpix=16;
end

if strcmp(ext,'.hdr') || strcmp(ext,'.ímg')
   outnm_h = [path base '.hdr'];
   hdr.magic = char([110,105,49,0]);
else
   outnm_h = niftiname;
end

%
% Write Header
%

f9 = fopen(outnm_h,'w','l');
if(f9 == -1)
  fprintf('ERROR: could not open %s\n',niftiname);
  return;
end

%
% Create field for header that can be pointed at
%
fwrite(f9,char(zeros(1,hdr.vox_offset+10)), 'char');

% sizeof_hdr
fseek(f9,0,'bof');
fwrite(f9,hdr.sizeof_hdr,   'int32');

% data_type
fseek(f9,4,'bof');
fwrite(f9,hdr.data_type,    'char');

% db_name
fseek(f9,14,'bof'); 
fwrite(f9,hdr.db_name,      'char');

% extents
fseek(f9,32,'bof'); 
fwrite(f9,hdr.extents,      'int32');

% session_error
fseek(f9,36,'bof'); 
fwrite(f9,hdr.session_error,'int16');

% regular
fseek(f9,38,'bof'); 
fwrite(f9,hdr.regular,      'char');

% dim_info
fseek(f9,39,'bof'); 
fwrite(f9,hdr.dim_info,     'char');

% dim
fseek(f9,40,'bof'); 
fwrite(f9,hdr.dim,          'int16');

% intent_p1
fseek(f9,56,'bof'); 
fwrite(f9,hdr.intent_p1,    'float');

% intent_p2
fseek(f9,60,'bof'); 
fwrite(f9,hdr.intent_p2,    'float');

% intent_p3
fseek(f9,64,'bof'); 
fwrite(f9,hdr.intent_p3,    'float');

% intent_code
fseek(f9,68,'bof'); 
fwrite(f9,hdr.intent_code,  'int16');

% datatype
fseek(f9,70,'bof'); 
fwrite(f9,hdr.datatype,     'int16');

% bitpix
fseek(f9,72,'bof'); 
fwrite(f9,hdr.bitpix,       'int16');

% slice_start
fseek(f9,74,'bof'); 
fwrite(f9,hdr.slice_start,  'int16');

% pixdim
fseek(f9,76,'bof'); 
fwrite(f9,hdr.pixdim,       'float');

% vox_offset
fseek(f9,108,'bof'); 
fwrite(f9,hdr.vox_offset,   'float');

% scl_slope
fseek(f9,112,'bof'); 
fwrite(f9,hdr.scl_slope,    'float');

% scl_inter
fseek(f9,116,'bof'); 
fwrite(f9,hdr.scl_inter,    'float');

% slice_end
fseek(f9,120,'bof'); 
fwrite(f9,hdr.slice_end,    'int16');

% slice_code
fseek(f9,122,'bof'); 
fwrite(f9,hdr.slice_code,   'uint8');

% xyzt_units
fseek(f9,123,'bof'); 
fwrite(f9,hdr.xyzt_units,   'uint8');

% cal_max
fseek(f9,124,'bof'); 
fwrite(f9,hdr.cal_max,      'float');

% cal_min
fseek(f9,128,'bof'); 
fwrite(f9,hdr.cal_min,      'float');

% slice_duration
fseek(f9,132,'bof'); 
fwrite(f9,hdr.slice_duration,'float');

% toffset
fseek(f9,136,'bof'); 
fwrite(f9,hdr.toffset,       'float');

% glmax
fseek(f9,140,'bof'); 
fwrite(f9,hdr.glmax,         'int32');

% glmin
fseek(f9,144,'bof'); 
fwrite(f9,hdr.glmin,         'int32');

% descrip
fseek(f9,148,'bof');
fwrite(f9,hdr.descrip,       'char');

% aux_file
fseek(f9,228,'bof');
fwrite(f9,hdr.aux_file,      'char');

% qform_code
fseek(f9,252,'bof');
fwrite(f9,hdr.qform_code,    'int16');

% sform_code
fseek(f9,254,'bof');
fwrite(f9,hdr.sform_code,    'int16');

% quatern_b
fseek(f9,256,'bof');
fwrite(f9,hdr.quatern_b,     'float');

% quatern_c
fseek(f9,260,'bof');
fwrite(f9,hdr.quatern_c,     'float');

% quatern_d
fseek(f9,264,'bof');
fwrite(f9,hdr.quatern_d,     'float');

% quatern_x
fseek(f9,268,'bof');
fwrite(f9,hdr.quatern_x,     'float');

% quatern_y
fseek(f9,272,'bof');
fwrite(f9,hdr.quatern_y,     'float');

% quatern_z
fseek(f9,276,'bof');
fwrite(f9,hdr.quatern_z,     'float');

% srow_x
fseek(f9,280,'bof');
fwrite(f9,hdr.srow_x,        'float');

% srow_y
fseek(f9,296,'bof');
fwrite(f9,hdr.srow_y,        'float');

% srow_z
fseek(f9,312,'bof');
fwrite(f9,hdr.srow_z,        'float');

% intent_name
fseek(f9,328,'bof');
fwrite(f9,hdr.intent_name,   'char');

% magic
fseek(f9,344,'bof');
fwrite(f9,hdr.magic,         'char');


%
%  Write Data
% 

if strcmp(outnm_h,niftiname)
	fseek(f9,hdr.vox_offset,'bof');

	if isfloat(data)  
	 % 'float'
	  nitems = fwrite(f9,data,'float');
	else
	  nitems = fwrite(f9,data,'int16');
	end

	pix = prod(size(data));

	fclose(f9);
else
	fclose(f9);

	f10 = fopen([path base '.img']);
	if isfloat(data)  
	 % 'float'
	  nitems = fwrite(f10,data,'float');
	else
	  nitems = fwrite(f1,data,'int16');
	end

	pix = prod(size(data));

	fclose(f10);
end

if(pix ~= nitems)
  fprintf('ERROR: tried to write %d, but only wrote %d',pix,nitems);
  return;
end



err = 0;
return;


