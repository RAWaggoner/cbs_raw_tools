function hdr = rd_nifti_hdr(niftiname)
%_
% Usage: hdr = rd_nifti_hdr(niftiname)
%
%
% niftiname - name of nifti file to write
% data - data array
% hdr - structure containing nifti header 
%
%
%
% R. Allen Waggoner, RIKEN-CBS
% version = 2019.02.19
%
%   (c) RIKEN 2019, 2019. All rights reserved. 
%


f9 = fopen(niftiname,'r','l');
if(f9 == -1)
  fprintf('ERROR: could not open %s\n',niftiname);
  return;
end

hdr.sizeof_hdr = fread(f9,1,'int');

fseek(f9,4,'bof');
hdr.data_type       = fscanf(f9,'%c',10);

fseek(f9,14,'bof');
hdr.db_name         = fscanf(f9,'%c',18);

fseek(f9,32,'bof');
hdr.extents         = fread(f9, 1,'int');

fseek(f9,36,'bof');
hdr.session_error   = fread(f9, 1,'short');

fseek(f9,38,'bof');
hdr.regular         = fread(f9, 1,'char');

fseek(f9,39,'bof');
hdr.dim_info        = fread(f9, 1,'uint8');

fseek(f9,40,'bof');
hdr.dim             = fread(f9, 8,'int16');

fseek(f9,56,'bof');
hdr.intent_p1       = fread(f9, 1,'float');

fseek(f9,60,'bof');
hdr.intent_p2       = fread(f9, 1,'float');

fseek(f9,64,'bof');
hdr.intent_p3       = fread(f9, 1,'float');

fseek(f9,68,'bof');
hdr.intent_code     = fread(f9, 1,'int16');

fseek(f9,70,'bof');
hdr.datatype        = fread(f9, 1,'int16');

fseek(f9,72,'bof');
hdr.bitpix          = fread(f9, 1,'int16');

fseek(f9,74,'bof');
hdr.slice_start     = fread(f9, 1,'int16');

fseek(f9,76,'bof');
hdr.pixdim          = fread(f9, 8,'float');

fseek(f9,108,'bof');
hdr.vox_offset      = fread(f9, 1,'float');

fseek(f9,112,'bof');
hdr.scl_slope       = fread(f9, 1,'float');

fseek(f9,116,'bof');
hdr.scl_inter       = fread(f9, 1,'float');

fseek(f9,120,'bof');
hdr.slice_end       = fread(f9, 1,'int16');

fseek(f9,122,'bof');
hdr.slice_code      = fread(f9, 1,'uint8');

fseek(f9,123,'bof');
hdr.xyzt_units      = fread(f9, 1,'uint8');

fseek(f9,124,'bof');
hdr.cal_max         = fread(f9, 1,'float');

fseek(f9,128,'bof');
hdr.cal_min         = fread(f9, 1,'float');

fseek(f9,132,'bof');
hdr.slice_duration  = fread(f9, 1,'float');

fseek(f9,136,'bof');
hdr.toffset         = fread(f9, 1,'float');

fseek(f9,140,'bof');
hdr.glmax           = fread(f9, 1,'int32');

fseek(f9,144,'bof');
hdr.glmin           = fread(f9, 1,'int32');

fseek(f9,148,'bof');
hdr.descrip         = fscanf(f9,'%c',80);

fseek(f9,228,'bof');
hdr.aux_file        = fscanf(f9,'%c',24);

fseek(f9,252,'bof');
hdr.qform_code      = fread(f9, 1,'int16');

fseek(f9,254,'bof');
hdr.sform_code      = fread(f9, 1,'int16');

fseek(f9,256,'bof');
hdr.quatern_b       = fread(f9, 1,'float');

fseek(f9,260,'bof');
hdr.quatern_c       = fread(f9, 1,'float');

fseek(f9,264,'bof');
hdr.quatern_d       = fread(f9, 1,'float');

fseek(f9,268,'bof');
hdr.quatern_x       = fread(f9, 1,'float');

fseek(f9,272,'bof');
hdr.quatern_y       = fread(f9, 1,'float');

fseek(f9,276,'bof');
hdr.quatern_z       = fread(f9, 1,'float');

fseek(f9,280,'bof');
hdr.srow_x          = fread(f9, 4,'float');

fseek(f9,296,'bof');
hdr.srow_y          = fread(f9, 4,'float');

fseek(f9,312,'bof');
hdr.srow_z          = fread(f9, 4,'float');

fseek(f9,328,'bof');
hdr.intent_name     = fscanf(f9,'%c',16);

fseek(f9,344,'bof');
hdr.magic           = fscanf(f9,'%c',4);

fclose(f9);

if (hdr.qform_code == 1)
   hdr.qform = quaternion2qform(hdr.quatern_b,hdr.quatern_c,hdr.quatern_d,hdr.quatern_x,hdr.quatern_y,hdr.quatern_z,hdr.pixdim);
end

if (hdr.sform_code == 1)
  hdr.sform = [[hdr.srow_x hdr.srow_y hdr.srow_z]'; 0 0 0 1];
end

return;
