function displayTree(treeBuilder)

import uiextras.jTree.*
f = figure();
t = Tree('Parent',f);

analysisTree = treeBuilder.getStructure();

parent = TreeNode('Name', analysisTree.get(1), 'Parent', t.Root);
id = 1;
parent.expand();

build(id, parent);

    function build(id, node)
        for child = analysisTree.getchildren(id)
            import uiextras.jTree.*
            if analysisTree.isleaf(child)
                TreeNode('Name', analysisTree.get(child), 'Parent', node);
                node.expand();
                return
            end
            childNode = TreeNode('Name', analysisTree.get(child), 'Parent', node);
            node.expand();
            build(child, childNode);
        end
    end

end



