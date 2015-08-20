classdef matrixQueue < handle
  properties ( Access = public )
    elems = [];
    last = 0;
    maxSize = 0;
  end
  methods
    function this = matrixQueue(maxSize)
        this.maxSize = maxSize;
    end
    function push(this, elem)
      if this.last == this.maxSize
        this.elems = circshift(this.elems, -1, 3);
      else
        this.last = this.last + 1;
      end
      this.elems(:, :, this.last) = elem;
    end
    function ret = empty(this)
      ret = (this.last == 0);
    end
    function elem = front(this)
      if this.empty()
        error('Empty Queue');
      end
      elem = this.elems(1);
    end
    function clear(this)
      this.last = 0;
      this.elems = [];
    end
%     function elems = getElements(this)
%       elems = this.elems(:, :, 1 : this.last);
%     end   
    function n = size(this)
      n = this.last;
    end    
    function ret = isFull(this)
      ret = (this.last == this.maxSize);
    end
    function removeLast(this)
        this.last = this.last - 1;
    end
    function dim = getDimension(this)
        [dim1, dim2, ~] = size(this.elems);
        dim = [dim1, dim2];
    end
  end
end