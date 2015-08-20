classdef queue < handle
  properties ( Access = public )
    elems = zeros(1,1);
    last = 0;
    maxSize = 0;
  end
  methods
    function this = queue(maxSize)
        this.maxSize = maxSize;
    end
    function initialize(this, value)
        this.elems = ones(1, this.maxSize) * value;
        this.last = this.maxSize;
    end
    function push(this, elem)
      if this.last == this.maxSize
        this.elems = circshift(this.elems, -1, 2);
      else
        this.last = this.last + 1;
      end
      this.elems(this.last) = elem;
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
    end
    function elems = getElements(this)
      elems = this.elems(1 : this.last);
    end
    
    function n = size(this)
      n = this.last;
    end
  end
end