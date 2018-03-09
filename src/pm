#!/tools/bin/python
import os
import shutil
import pprint
from argparse import ArgumentParser

from dd.runtime import api
api.load('pyyaml')

import yaml


def getFolderStructure(var, parent=None, parent_permission=0):
    # analyse yaml file and return folder structure
    path_list = []
    for k, v in var.iteritems():
        if var.has_key('permission'):
            parent_permission = var['permission']

        if isinstance(v, list):
            if not parent:
                # add first parent to list
                path_list.append('%s-%s' % (k, parent_permission))

            # get parent name
            for e in v:
                tmp = k
                if parent:
                    tmp = '%s/%s' % (parent, k)

                # add keys with permission value
                chk_for_duplicates = '%s-%s' % (tmp, parent_permission)
                if chk_for_duplicates not in path_list:
                    path_list.append('%s-%s' % (tmp, parent_permission))

                path_list.extend(getFolderStructure(e, tmp, parent_permission))

        if isinstance(v, dict):
            path_list.extend(getFolderStructure(v, parent, parent_permission))

        if isinstance(v, str) and k == 'value':
            if var.has_key('permission'):
                path_list.append('%s/%s-%s' % (parent, v, var['permission']))
            else:
                path_list.append('%s/%s-%s' % (parent, v, parent_permission))
    return path_list


def get_yaml_data():

    # get yaml data based in "PROJMAN_TEMPLATES"
    def getNewTypeDataFromYaml(yaml_file_path, yaml_data):
        yaml_tmp_data = {}
        with open(yaml_file_path, 'r') as info:
            yaml_tmp_data = yaml.load(info)

        # get keys as per final yaml data for validation
        final_keys = []
        for e_data in yaml_data:
            final_keys.append(e_data['value'].keys()[0])

        new_key_data = []
        for e_data in yaml_tmp_data:
            new_key = e_data['value'].keys()[0]
            if new_key not in final_keys:
                new_key_data.append(e_data)
        return new_key_data

    # get unique types based on "PROJMAN_TEMPLATES"
    yaml_data = []
    valid_key_data = {}
    info = os.getenv('PROJMAN_TEMPLATES')
    env_paths = info.split(':')
    for e_path in env_paths:
        yaml_files = os.listdir(e_path)
        for e_y_file in yaml_files:
            if e_y_file.endswith('.yaml'):
                yaml_file_path = e_path + '/' + e_y_file
                valid_key_data = getNewTypeDataFromYaml(yaml_file_path, yaml_data)
                if valid_key_data:
                    yaml_data.extend(valid_key_data)

    return yaml_data


def list_projects(project_path, optional_types):
    # sub commands 1
    valid_prj_list = []
    if optional_types == 'all':
        valid_prj_list.append(os.listdir(project_path))
    else:

        optional_types_list = optional_types.split(',')

        for e_prj_dir in os.listdir(project_path):
            path = project_path + '/' + e_prj_dir
            prj_sub_dirs = os.listdir(path)
            for e_op_typ in optional_types_list:
                if e_op_typ in prj_sub_dirs:
                    valid_prj_list.append(e_prj_dir)
                    break

    for e_prj in valid_prj_list:
        print e_prj


def create_dirs(paths, project_path, NAME):
    # sub commands 2
    # create folder structure in project path
    for e_path in paths:
        path = project_path + '/' + NAME + '/' + e_path.split('-')[0]
        permission_code = int(e_path.split('-')[1], 8)

        # print permission_code
        # check whether path contains file or not
        if not '.' in os.path.basename(path):
            if not os.path.exists(path):
                os.makedirs(path)
                if permission_code != 0:
                    os.chmod(path, permission_code)
        else:
            dir_path = os.path.dirname(path)
            if not os.path.exists(dir_path):
                os.makedirs(dir_path)

            with open(path, 'w') as fid:
                pass
            if permission_code != 0:
                os.chmod(path, permission_code)

        # print path


def delete_projects(project_path, optional_types, project_name):
    # sub commands 3
    project_path_final = os.path.join(project_path, project_name)
    valid_prj_list = []
    if optional_types == "all":
        shutil.rmtree(project_path_final)
        return
    else:
        optional_types_list = optional_types.split(',')
        # get projects to delete
        prj_sub_dirs = os.listdir(project_path_final)
        for e_op_typ in optional_types_list:
            if e_op_typ in prj_sub_dirs:
                valid_prj_list.append(project_path_final + '/' + e_op_typ)
                break

    for e_v_prj in valid_prj_list:
        shutil.rmtree(e_v_prj)


def list_types_projects():
    # sub commands 4
    for e_data in get_yaml_data():
        print e_data['value'].keys()[0]


def describe_projects(paths):
    # sub commands 5
    # print data in yaml format
    def chk(length):
        # return line with tabs as per input
        line = ''
        if length == 1:
            return line
        for i in range(length - 2):
            line = line + '    '
        return line + '  - '

    prev_item = []
    for e in paths[1:]:
        e = e.split('-')[0]
        item_split = e.split('/')
        item_len = len(item_split)
        if '/'.join(e.split('/')[:-1]) not in prev_item:
            print chk(item_len - 1) + item_split[-2] + ':'
            prev_item.append('/'.join(e.split('/')[:-1]))
        print chk(item_len) + item_split[-1]


def process(args):
    yaml_data = get_yaml_data()

    # sub_command process
    if args.sub_command == 'create' or args.sub_command == 'describe':
        for e_data in yaml_data:

            type_chk = e_data['value'].keys()[0]

            if args.type == 'all':
                process_chk = True
            elif type_chk == args.type:
                process_chk = True
            else:
                process_chk = False

            if process_chk:
                if args.sub_command == 'create':
                    create_dirs(getFolderStructure(e_data), args.project_path, args.NAME)

                if args.sub_command == 'describe':
                    describe_projects(getFolderStructure(e_data))

    elif args.sub_command == 'list':
        list_projects(args.project_path, args.type)

    elif args.sub_command == 'delete':
        delete_projects(args.project_path, args.type, args.NAME)

    elif args.sub_command == 'types':
        list_types_projects()


def parse_arguments():
    """
    process the arguments
    """
    parser = ArgumentParser(description="""Sample usage :
                                           projectManager --t TYPE --p PROJECT_PATH""")

    parser.add_argument('-t', '--type', type=str,
                        dest='type', default='all',
                        help=' maya, hudini & nuke')

    parser.add_argument('-p', '--path', type=str,
                        dest='project_path', default=None,
                        help='The base path in which to create the project. If not supplied, it uses a default '
                             'project path')

    parser.add_argument("sub_command", type=str,
                        help="list or create or delete or types or describe")

    parser.add_argument("NAME",
                        help="The name of the project to create, delete, or run types on.",
                        default='DEFAULT', nargs='?')

    args = parser.parse_args()

    # validations
    if not args.project_path:
        if os.getenv('PROJMAN_LOCATION'):
            args.project_path = os.getenv('PROJMAN_LOCATION')
        else:
            args.project_path = 'default_path'

    if not args.sub_command:
        parser.error("\n Please specify sub_command")

    if args.sub_command == 'create' and args.NAME == 'DEFAULT':
        parser.error("\n Please specify NAME")

    return args


if __name__ == '__main__':
    process(parse_arguments())
