function disconnect(dev)
    delete(dev);
    clear dev;
    evalin('base','clear dev');
end