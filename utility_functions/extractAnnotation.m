function obj = extractAnnotation(Annot,j)

obj.vehicleType = Annot{1, 1}{j};
obj.occlusion = Annot{1, 3}(j);
obj.truncation = Annot{1, 2}(j);
obj.angle = Annot{1, 4}(j);
obj.bbox = [Annot{1, 5}(j) Annot{1, 6}(j) Annot{1, 7}(j) Annot{1, 8}(j)];
obj.width = obj.bbox(3) - obj.bbox(1);
obj.height = obj.bbox(4) - obj.bbox(2);

end