function catmullClarkSubdivision(vertices, faces, Sharpness) {
    var newVertices = [];
    var newFaces = [];

    //switch this back to list maybe?
    var sharpEdges = {};
    var sharpVertices = [];
    
    var edgeMap = {};
    // This function tries to insert the centroid of the edge between
    // vertices a and b into the newVertices array.
    // If the edge has already been inserted previously, the index of
    // the previously inserted centroid is returned.
    // Otherwise, the centroid is inserted and its index returned.
    function getOrInsertEdge(a, b, centroid) {
        var edgeKey = a < b ? a + ":" + b : b + ":" + a;
        if (edgeKey in edgeMap) {
            return edgeMap[edgeKey];
        } else {
            var idx = newVertices.length;
            newVertices.push(centroid);
            edgeMap[edgeKey] = idx;
            return idx;
        }
    }

    
    // TODO: Implement a function that computes one step of the Catmull-Clark subdivision algorithm.
    //
    // Input:
    // `vertices`: An array of Vectors, describing the positions of every vertex in the mesh
    // `faces`: An array of arrays, specifying a list of faces. Every face is a list of vertex
    //          indices, specifying its corners. Faces may contain an arbitrary number
    //          of vertices (expect triangles, quadrilaterals, etc.)
    //
    // Output: Fill in newVertices and newFaces with the vertex positions and
    //         and faces after one step of Catmull-Clark subdivision.
    // It should hold:
    //         newFaces[i].length == 4, for all i
    //         (even though the input may consist of any of triangles, quadrilaterals, etc.,
    //          Catmull-Clark will always output quadrilaterals)
    //
    // Pseudo code follows:

    //push sharp vertices in their own list

    // for (var i = 0; i < vertices.length; i++) {
    //     sharpVertices.push(vertices[i].clone());
    // }


    // //makes sharp edges doesnt work
    // for (var i = 0; i < faces.length; i++) {
    //     var face = faces[i];
    //     for (var v = 0; v < face.length; v++) {
    //         var v0 = face[v];
    //         var v1 = face[(v + 1) % face.length];
    //         //inserting edges
    //         var edgeKey = v0 < v1 ? v0 + ":" + v1 : v1 + ":" + v0;
    //         if (!(edgeKey in sharpEdges)) {
    //             sharpEdges[edgeKey] = i;
    //         }
    //     }
    // }


    // ************************************
    // ************** Step 1 **************
    // ******** Linear subdivision ********
    // ************************************


    //adding vertices to the newVertices list

    //find a way to make it do the shrapness calculation before the other stuff but still not make it go past 10
    // for (var s = 0; s < Sharpness; s++){
    
    for (var i = 0; i < vertices.length; i++){
        newVertices.push(vertices[i].clone());
    }

    for (var i = 0; i < faces.length; i++){
        var face = faces[i];
        //map v to vertices list to get new verts
        newVertices.push(centroid(face.map(v => vertices[v])));

        // for indexing
        var facePointIndex = newVertices.length - 1;


        for (var v = 0; v < face.length; v++ ){
            // either makes this the previous point or last point if on first iteration
            var v0 = face[(v + face.length - 1) % face.length];
            var v1 = face[v]
            //makes this one the next point unless index is last then it is first point
            var v2 = face[(v + face.length + 1) % face.length];

            //add points to edges and push them as faces
            edgePointA = getOrInsertEdge(v0, v1, centroid([vertices[v0], vertices[v1]]));
            edgePointB = getOrInsertEdge(v1, v2, centroid([vertices[v1], vertices[v2]]));
            newFaces.push([facePointIndex, edgePointA, v1, edgePointB]);
        }
    }
// }
 
    // ************************************
    // ************** Step 2 **************
    // ************ Averaging *************
    // ************************************


var avgV = [];
var avgN = [];

//initializing vectors and 0s
for (var i = 0; i < newVertices.length; i++) {
    avgV.push(new Vector(0, 0, 0));
    avgN.push(0);
}

//going through each face and finding the centroid to get an average for smoothing
for (var j = 0; j < newFaces.length; j++) {
    var face = newFaces[j];
    var c = centroid(face.map(v => newVertices[v]));

    //avg the verts
    for (var v = 0; v < face.length; v++) {
        avgV[face[v]] = avgV[face[v]].add(c);
        avgN[face[v]] += 1;
    }
}

//dividing by total number
for (var k = 0; k < avgV.length; k++) {
    avgV[k] = avgV[k].divide(avgN[k]);
}
    
    // ************************************
    // ************** Step 3 **************
    // ************ Correction ************
    // ************************************

    //applying correction to shape
    for (var i = 0; i < avgV.length; i++) {
        newVertices[i] = Vector.lerp(newVertices[i], avgV[i], (-Sharpness/10*4 + 4.4) / avgN[i]);
    }
    
    // Do not remove this line
    return new Mesh(newVertices, newFaces);
};

//helper function to calculate centroid
function centroid(vectors) {
    var sum = new Vector(0, 0, 0);
    for (var i = 0; i < vectors.length; i++) {
        sum = sum.add(vectors[i]);
    }
    var centroid = sum.divide(vectors.length);

    return centroid;
}

function extraCreditMesh() {

    //took the cube and make it into more of a trapezoid
    var vertices = [
        new Vector(-1, -1, -1), 
        new Vector(-.8, -.8,  1), // 
        new Vector(-1,  1, -1), // ba l t
        new Vector(-.8,  .2,  1), // fr l t 
        new Vector( 1, -1, -1), //ba r b
        new Vector( .2, -.8,  1), // fr r b
        new Vector( 1,  1, -1), // ba r t
        new Vector( .2,  .2,  1) // f r t
    ];
    var faces = [
        [0, 1, 3, 2], [4, 5, 7, 6],
        [0, 1, 5, 4], [2, 3, 7, 6],
        [0, 2, 6, 4], [1, 3, 7, 5]
    ]
    
    return new Mesh(vertices, faces);
}

var Task2 = function(gl) {
    this.pitch = 0;
    this.yaw = 0;
    this.subdivisionLevel = 0;
    this.Sharpness = 1;
    this.selectedModel = 0;
    this.gl = gl;
    
    gl.enable(gl.DEPTH_TEST);
    gl.depthFunc(gl.LEQUAL);
    
    this.baseMeshes = [];
    for (var i = 0; i < 6; ++i)
        this.baseMeshes.push(this.baseMesh(i).toTriangleMesh(gl));
    
    this.computeMesh();
}

Task2.prototype.setSubdivisionLevel = function(subdivisionLevel) {
    this.subdivisionLevel = subdivisionLevel;
    this.computeMesh();
}
Task2.prototype.setSharpnessLevel = function(Sharpness) {
    this.Sharpness = Sharpness;
    this.computeMesh();
}

Task2.prototype.selectModel = function(idx) {
    this.selectedModel = idx;
    this.computeMesh();
}

Task2.prototype.baseMesh = function(modelIndex) {
    switch(modelIndex) {
    case 0: return createCubeMesh(); break;
    case 1: return createTorus(8, 4, 0.5); break;
    case 2: return createSphere(4, 3); break;
    case 3: return createIcosahedron(); break;
    case 4: return createOctahedron(); break;
    case 5: return extraCreditMesh(); break;
    }
    return null;
}

Task2.prototype.computeMesh = function() {
    var mesh = this.baseMesh(this.selectedModel);
    
    for (var i = 0; i < this.subdivisionLevel; ++i)
        mesh = catmullClarkSubdivision(mesh.vertices, mesh.faces,this.Sharpness - i);
    
    this.mesh = mesh.toTriangleMesh(this.gl);
}

Task2.prototype.render = function(gl, w, h) {
    gl.viewport(0, 0, w, h);
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    
    var projection = Matrix.perspective(35, w/h, 0.1, 100);
    var view =
        Matrix.translate(0, 0, -5).multiply(
        Matrix.rotate(this.pitch, 1, 0, 0)).multiply(
        Matrix.rotate(this.yaw, 0, 1, 0));
    var model = new Matrix();
    
    if (this.subdivisionLevel > 0)
        this.baseMeshes[this.selectedModel].render(gl, model, view, projection, false, true, new Vector(0.7, 0.7, 0.7));

    this.mesh.render(gl, model, view, projection);
}

Task2.prototype.dragCamera = function(dx, dy) {
    this.pitch = Math.min(Math.max(this.pitch + dy*0.5, -90), 90);
    this.yaw = this.yaw + dx*0.5;
}
