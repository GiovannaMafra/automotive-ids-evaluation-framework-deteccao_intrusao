import os


def expand_user_paths(obj):
    """
    Recursively expand ~ (home directory) in all string values within a dictionary or list.
    
    Args:
        obj: Dictionary, list, or string to process
        
    Returns:
        The same type of object with expanded paths
    """
    if isinstance(obj, dict):
        return {key: expand_user_paths(value) for key, value in obj.items()}
    elif isinstance(obj, list):
        return [expand_user_paths(item) for item in obj]
    elif isinstance(obj, str):
        return os.path.expanduser(obj)
    else:
        return obj
