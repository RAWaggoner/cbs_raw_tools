function [data hdr] = rd_nifti(niftiname)
%_
% Usage: [data hdr] = rd_nifti(niftiname)
%
%
% niftiname - name of nifti file to write
% data - data array
% hdr - structure containing nifti header 
%
%
%
% R. Allen Waggoner, RIKEN-CBS
% version = 2020.10.24
%
%   (c) RIKEN 2019, 2020. All rights reserved. 
%

[path base ext] = fileparts(niftiname);

if strcmp(ext,'.nii')
	hdr = rd_nifti_hdr(niftiname);
else
	hdr = rd_nifti_hdr([path base '.hdr']);
end

f9 = fopen(niftiname,'r');
if(f9 == -1)
  fprintf('ERROR: could not open %s\n',niftiname);
  return;
end

dim5 = hdr.dim(5);
if (dim5 == 0)
	dim5=1;
end

if strcmp(ext,'.nii')
	fseek(f9,hdr.vox_offset,'bof');
	if (hdr.datatype == 16)
		[data count] = fread(f9,hdr.dim(2)*hdr.dim(3)*hdr.dim(4)*dim5,'float');
	else
		[data count] = fread(f9,hdr.dim(2)*hdr.dim(3)*hdr.dim(4)*dim5,'int16');
	end
else
	f10 = fopen([base '.img'],'r');
	if (hdr.datatype == 16)
		[data count] = fread(f10,hdr.dim(2)*hdr.dim(3)*hdr.dim(4)*dim5,'float');
	else
		[data count] = fread(f10,hdr.dim(2)*hdr.dim(3)*hdr.dim(4)*dim5,'int16'); 
	end
	fclose(f10);
end


data = reshape(data, hdr.dim(2),hdr.dim(3),hdr.dim(4),dim5);

fclose(f9);


return;
