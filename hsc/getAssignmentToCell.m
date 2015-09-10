function cell = getAssignmentToCell(index, imgParams)
%getAssignmentToCell Determine cell of a patch.
% cell = getAssignmentToCell(index, imgParams) computes  the cell to which
% a certain patch identified by its index belongs to.

% initialization (for easier reading)
height = imgParams.imgSize(1,1);
width  = imgParams.imgSize(1,2);
patchSizeH = imgParams.patchSize(1,1);
patchSizeW = imgParams.patchSize(1,2);

% how many patches were created per row resp. per column
amountCols = width  - patchSizeW + 1;
amountRows = height - patchSizeH + 1;

% to which row of patches resp. column of patches does the patch belong to
patchRow = ceil(index / amountCols);
patchCol = index - (patchRow - 1) * amountCols;

% how many pixels are in one cell
cellSizeH = amountRows / imgParams.amountCells(1);
cellSizeW = amountCols / imgParams.amountCells(2);

% to which row of cells resp. column of cells does the patch row/column belong to
cellRow = ceil(patchRow / cellSizeH);
cellCol = ceil(patchCol / cellSizeW);

cell = [cellRow cellCol];

end
