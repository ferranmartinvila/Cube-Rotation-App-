function varargout = trackBall(varargin)
% TRACKBALL MATLAB code for trackBall.fig
%      TRACKBALL, by itself, creates a new TRACKBALL or raises the existing
%      singleton*.
%
%      H = TRACKBALL returns the handle to a new TRACKBALL or the handle to
%      the existing singleton*.
%
%      TRACKBALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBALL.M with the given input arguments.
%
%      TRACKBALL('Property','Value',...) creates a new TRACKBALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBall

% Last Modified by GUIDE v2.5 11-Jan-2017 16:52:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBall_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBall_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trackBall is made visible.
function trackBall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBall (see VARARGIN)


set(hObject,'WindowButtonDownFcn',{@my_MouseClickFcn,handles.cube});
set(hObject,'WindowButtonUpFcn',{@my_MouseReleaseFcn,handles.cube});
axes(handles.cube);

handles.Cube=DrawCube(eye(3));

set(handles.cube,'CameraPosition',...
    [0 0 5],'CameraTarget',...
    [0 0 -5],'CameraUpVector',...
    [0 1 0],'DataAspectRatio',...
    [1 1 1]);

set(handles.cube,'xlim',[-3 3],'ylim',[-3 3],'visible','off','color','none');

%Pre-Reset Globals
sp = [0;0;0];
SetStartPoint(sp);
quat = [1;0;0;0];
SetQuat(quat);

% Choose default command line output for trackBall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackBall wait for user response (see UIRESUME)
% uiwait(handles.angle);

% --- Outputs from this function are returned to the command line.
function varargout = trackBall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%Ball rotation functions --------------
function SetStartPoint(point)
global start_point;
start_point = point;

function point = GetStartPoint()
global start_point;
point = start_point;
if(isempty(point) == 1)
    
   point = [0;0;0];
   
end

function SetEndPoint(point)
global end_point;
end_point = point;

function point = GetEndPoint()
global end_point;
point = end_point;
if(isempty(point) == 1)
    
   point = [0;0;0];
   
end

function SetQuat(Quat)
global quat;
quat = Quat;

function Quat = GetQuat()
global quat;
Quat = quat;
if(isempty(Quat) == 1)
    
   Quat = zeros(1,4);
   
end

function [rad] = GetRad()
rad = 5;
% -------------------------------------

function my_MouseClickFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.cube,'xlim');
ylim = get(handles.cube,'ylim');


mousepos= get(handles.cube,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

%Check if mouse is inside cube limits
if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    %Build start 3D point
    rad = GetRad();

    %First case
    if((xmouse*xmouse + ymouse*ymouse) < 0.5*(rad*rad))
       
        z = sqrt(rad*rad - xmouse*xmouse - ymouse*ymouse);
        start_point = [xmouse;ymouse;z];
        
    %Second case
    else
        
        z = (rad*rad)/(2*sqrt(xmouse*xmouse + ymouse*ymouse));
        start_point = [xmouse;ymouse;z] / sqrt(xmouse*xmouse + ymouse*ymouse + z*z);
        
    end
    
    %Set the initial point
    SetStartPoint(start_point);
    
    set(handles.angle,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});

else
    end_point =[0;0;0];
    SetEndPoint(end_point);
end
guidata(hObject,handles)

function my_MouseReleaseFcn(obj,event,hObject)
handles=guidata(hObject);
set(handles.angle,'WindowButtonMotionFcn','');

%Build the rotation axis
start_point = GetStartPoint();
end_point = GetEndPoint();

not_zeros = (end_point(1) ~= 0 || end_point(2)~= 0 || end_point(3)~= 0);
different = (end_point(1) ~= start_point(1) || end_point(2) ~= start_point(2) || end_point(3) ~= start_point(3));

if not_zeros && different

    rotaxis = (cross(start_point,end_point)/(norm(cross(start_point,end_point))));
    last_Rmat = quat2rotm(GetQuat());
    rotaxis = last_Rmat' * rotaxis;

    %Build the rotation angle
    angle = acos((end_point'*start_point) / (norm(start_point)*norm(end_point))) * 180/pi * 2;
    angle = check_zeros(angle);
    %Build the rotation quaternion from the axis and the angle
    current_quaternion = [cosd(angle/2);sind(angle/2)*rotaxis];
    current_quaternion = quaternion_product(GetQuat(), current_quaternion);
    SetQuat(current_quaternion);
    
end

guidata(hObject,handles);


function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.cube,'xlim');
ylim = get(handles.cube,'ylim');
mousepos=get(handles.cube,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

%Check if mouse is inside cube limits
if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)
    
    
    %Build end 3D point
    rad = GetRad();
    
    %First case
    if((xmouse*xmouse + ymouse*ymouse) < 0.5*(rad*rad))
       
        z = sqrt(rad*rad - xmouse*xmouse - ymouse*ymouse);
        end_point = [xmouse;ymouse;z];
        
    %Second case
    else
        
        z = (rad*rad)/(2*sqrt(xmouse*xmouse + ymouse*ymouse));
        end_point = [xmouse;ymouse;z] / sqrt(xmouse*xmouse + ymouse*ymouse + z*z);
        
    end
   
    
    %Set the End Point
    SetEndPoint(end_point);
    start_point = GetStartPoint();
    
    if(start_point ~= end_point)
      
        %Build the rotation axis
        rotaxis = (cross(start_point,end_point)/(norm(cross(start_point,end_point))));
        last_Rmat = quat2rotm(GetQuat());
        rotaxis = last_Rmat' * rotaxis;

        %Build the rotation angle
        angle = acos((end_point'*start_point) / (norm(start_point)*norm(end_point))) * 180/pi * 2;

        %Build the rotation quaternion from the axis and the angle
        current_quaternion = [cosd(angle/2);sind(angle/2)*rotaxis];
        current_quaternion = quaternion_product(GetQuat(), current_quaternion);
        Rmat = quat2rotm(current_quaternion);

        %Update All the panels --------------------------------
        angle = check_zeros(angle);
        current_quaternion = check_zeros(current_quaternion);
        %Quaternion Panel -------------------------------------
        set(handles.quaternion_i, 'String', current_quaternion(1));
        set(handles.quaternion_X, 'String', current_quaternion(2));
        set(handles.quaternion_Y, 'String', current_quaternion(3));
        set(handles.quaternion_Z, 'String', current_quaternion(4));


        % Panel Euler Axis and Angle ------------------------------
        [e_axis,e_angle] = rotMat2Eaa(Rmat);
        e_axis = check_zeros(e_axis);
        e_angle = check_zeros(e_angle);
        set(handles.e_axis_x, 'String', e_axis(1));
        set(handles.e_axis_y, 'String', e_axis(2));
        set(handles.e_axis_z, 'String', e_axis(3));
        set(handles.e_axis_angle, 'String', e_angle);
        set(handles.e_axis_slider, 'Value', e_angle);

        %Euler Angles --------------------------------------------
        [phi, theta, psi] = rotM2eAngles(Rmat);
        phi = check_zeros(phi);
        theta = check_zeros(theta);
        psi = check_zeros(psi);
        set(handles.X_angle, 'String', phi);
        set(handles.Y_angle, 'String', theta);
        set(handles.Z_angle, 'String', psi);

        %Panel Rotation Vector ------------------------------------
        rot_vec = e_axis * e_angle;
        rot_vec = check_zeros(rot_vec);
        set(handles.rot_vec_x, 'String', rot_vec(1));
        set(handles.rot_vec_y, 'String', rot_vec(2));
        set(handles.rot_vec_z, 'String', rot_vec(3));

        %Update Matrix
        Rmat = check_zeros(Rmat);
        set(handles.rotmat1_1, 'String', Rmat(1));
        set(handles.rotmat1_2, 'String', Rmat(4));
        set(handles.rotmat1_3, 'String', Rmat(7));
        set(handles.rotmat2_1, 'String', Rmat(2));
        set(handles.rotmat2_2, 'String', Rmat(5));
        set(handles.rotmat2_3, 'String', Rmat(8));
        set(handles.rotmat3_1, 'String', Rmat(3));
        set(handles.rotmat3_2, 'String', Rmat(6));
        set(handles.rotmat3_3, 'String', Rmat(9));

        %Apply the rotation
        handles.Cube = RedrawCube(Rmat,handles.Cube);
        
    end
end
guidata(hObject,handles);

function h = DrawCube(R)

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

h = fill3(x,y,z, 1:6);

for q = 1:length(c)
    h(q).FaceColor = c(q,:);
end

function h = RedrawCube(R,hin)

h = hin;
c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

for q = 1:6
    h(q).Vertices = [x(:,q) y(:,q) z(:,q)];
    h(q).FaceColor = c(q,:);
end



function Matriz_Callback(hObject, eventdata, handles)
% hObject    handle to Matriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Matriz as text
%        str2double(get(hObject,'String')) returns contents of Matriz as a double


% --- Executes during object creation, after setting all properties.
function Matriz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Matriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function angle_Callback(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of angle as text
%        str2double(get(hObject,'String')) returns contents of angle as a double


% --- Executes during object creation, after setting all properties.
function angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vector_Callback(hObject, eventdata, handles)
% hObject    handle to vector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vector as text
%        str2double(get(hObject,'String')) returns contents of vector as a double


% --- Executes during object creation, after setting all properties.
function vector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in e_axis_calculate.
function e_axis_calculate_Callback(hObject, eventdata, handles)
% hObject    handle to e_axis_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
%Get euler principal angle and axis panel data ------------
vector(1) = str2double(get(handles.e_axis_x, 'String'));
vector(2) = str2double(get(handles.e_axis_y, 'String'));
vector(3) = str2double(get(handles.e_axis_z, 'String'));
angle = str2double(get(handles.e_axis_angle, 'String'));

if norm(vector) ~= 0
    vector = vector / norm(vector);
end
vector = check_zeros(vector);

%Calculate the rotation matrix & quaternion ---------------
if (angle == 0 || (vector(1) == 0 && vector(2) == 0 && vector(3) == 0))
    
    Rmat = [1,0,0;0,1,0;0,0,1];
    quat = [1;0;0;0];
    vector = [0;0;0];
    
else

    Rmat = Eaa2rotMat(vector, angle);
    quat = rotm2quat(Rmat);
    Rmat = check_zeros(Rmat);
    quat = check_zeros(quat);
    
end

set(handles.e_axis_x, 'String',vector(1));
set(handles.e_axis_y, 'String',vector(2));
set(handles.e_axis_z, 'String',vector(3));
set(handles.e_axis_angle, 'String',angle);
set(handles.e_axis_slider, 'Value',angle);
SetQuat(quat);


%Update other panels --------------------------------------
%Panel Rotation Matrix ------------------------------------
set(handles.rotmat1_1, 'String', Rmat(1));
set(handles.rotmat1_2, 'String', Rmat(4));
set(handles.rotmat1_3, 'String', Rmat(7));
set(handles.rotmat2_1, 'String', Rmat(2));
set(handles.rotmat2_2, 'String', Rmat(5));
set(handles.rotmat2_3, 'String', Rmat(8));
set(handles.rotmat3_1, 'String', Rmat(3));
set(handles.rotmat3_2, 'String', Rmat(6));
set(handles.rotmat3_3, 'String', Rmat(9));

%Panel Quaternion -----------------------------------------
set(handles.quaternion_i, 'String', quat(1));
set(handles.quaternion_X, 'String', quat(2));
set(handles.quaternion_Y, 'String', quat(3));
set(handles.quaternion_Z, 'String', quat(4));

%Panel Euler Angles ---------------------------------------
[phi, theta, psi] = rotM2eAngles(Rmat);
phi = check_zeros(phi);
theta = check_zeros(theta);
psi = check_zeros(psi);
set(handles.X_angle, 'String', phi);
set(handles.Y_angle, 'String', theta);
set(handles.Z_angle, 'String', psi);

%Panel Rotation Vector ------------------------------------
rot_vec = vector * (angle / (180/pi));
rot_vec = check_zeros(rot_vec);
set(handles.rot_vec_x, 'String', rot_vec(1));
set(handles.rot_vec_y, 'String', rot_vec(2));
set(handles.rot_vec_z, 'String', rot_vec(3));

%Apply the rotation ---------------------------------------
handles.Cube = RedrawCube(Rmat,handles.Cube);
    


% --- Executes on key press with focus on angle and none of its controls.
function angle_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function e_axis_slider_Callback(hObject, eventdata, handles)
% hObject    handle to e_axis_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.e_axis_angle, 'String', get(hObject, 'Value'));


% --- Executes during object creation, after setting all properties.
function e_axis_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_axis_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function e_axis_angle_Callback(hObject, eventdata, handles)
% hObject    handle to e_axis_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_axis_angle as text
%        str2double(get(hObject,'String')) returns contents of e_axis_angle as a double


% --- Executes during object creation, after setting all properties.
function e_axis_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_axis_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_axis_x_Callback(hObject, eventdata, handles)
% hObject    handle to e_axis_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_axis_x as text
%        str2double(get(hObject,'String')) returns contents of e_axis_x as a double


% --- Executes during object creation, after setting all properties.
function e_axis_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_axis_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_axis_y_Callback(hObject, eventdata, handles)
% hObject    handle to e_axis_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_axis_y as text
%        str2double(get(hObject,'String')) returns contents of e_axis_y as a double


% --- Executes during object creation, after setting all properties.
function e_axis_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_axis_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_axis_z_Callback(hObject, eventdata, handles)
% hObject    handle to e_axis_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_axis_z as text
%        str2double(get(hObject,'String')) returns contents of e_axis_z as a double


% --- Executes during object creation, after setting all properties.
function e_axis_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_axis_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in quaternion_calculate.
function quaternion_calculate_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get quaternion panel data --------------------------------
quaternion(1) = str2double(get(handles.quaternion_i, 'String'));
quaternion(2) = str2double(get(handles.quaternion_X, 'String'));
quaternion(3) = str2double(get(handles.quaternion_Y, 'String'));
quaternion(4) = str2double(get(handles.quaternion_Z, 'String'));
quaternion = quaternion';
q_norm = norm(quaternion);
if(q_norm == 0)
    
    quaternion = [1;0;0;0]; 

else
    
    quaternion = quaternion / norm(quaternion);

end
quaternion = check_zeros(quaternion);
set(handles.quaternion_i, 'String',quaternion(1));
set(handles.quaternion_X, 'String',quaternion(2));
set(handles.quaternion_Y, 'String',quaternion(3));
set(handles.quaternion_Z, 'String',quaternion(4));

%Calculate the rotation matrix & quaternion ---------------
Rmat = quat2rotm(quaternion);
SetQuat(quaternion)


%Update other panels --------------------------------------
% Panel Rotation Matrix -----------------------------------
Rmat = check_zeros(Rmat);
set(handles.rotmat1_1, 'String', Rmat(1));
set(handles.rotmat1_2, 'String', Rmat(4));
set(handles.rotmat1_3, 'String', Rmat(7));
set(handles.rotmat2_1, 'String', Rmat(2));
set(handles.rotmat2_2, 'String', Rmat(5));
set(handles.rotmat2_3, 'String', Rmat(8));
set(handles.rotmat3_1, 'String', Rmat(3));
set(handles.rotmat3_2, 'String', Rmat(6));
set(handles.rotmat3_3, 'String', Rmat(9));

% Panel Euler Axis and Angle ------------------------------
[e_axis,angle] = rotMat2Eaa(Rmat);
e_axis = check_zeros(e_axis);
angle = check_zeros(angle);
set(handles.e_axis_x, 'String', e_axis(1));
set(handles.e_axis_y, 'String', e_axis(2));
set(handles.e_axis_z, 'String', e_axis(3));
set(handles.e_axis_angle, 'String', angle);
set(handles.e_axis_slider, 'Value', angle);

%Euler Angles --------------------------------------------
[phi, theta, psi] = rotM2eAngles(Rmat);
phi = check_zeros(phi);
theta = check_zeros(theta);
psi = check_zeros(psi);
set(handles.X_angle, 'String', phi);
set(handles.Y_angle, 'String', theta);
set(handles.Z_angle, 'String', psi);

%Panel Rotation Vector ------------------------------------
rot_vec = e_axis * angle;
rot_vec = check_zeros(rot_vec);
set(handles.rot_vec_x, 'String', rot_vec(1));
set(handles.rot_vec_y, 'String', rot_vec(2));
set(handles.rot_vec_z, 'String', rot_vec(3));

%Apply the rotation ---------------------------------------
handles.Cube = RedrawCube(Rmat,handles.Cube);




function quaternion_X_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_X as text
%        str2double(get(hObject,'String')) returns contents of quaternion_X as a double


% --- Executes during object creation, after setting all properties.
function quaternion_X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_Y_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_Y as text
%        str2double(get(hObject,'String')) returns contents of quaternion_Y as a double


% --- Executes during object creation, after setting all properties.
function quaternion_Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_Z_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_Z as text
%        str2double(get(hObject,'String')) returns contents of quaternion_Z as a double


% --- Executes during object creation, after setting all properties.
function quaternion_Z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_i_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_i (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_i as text
%        str2double(get(hObject,'String')) returns contents of quaternion_i as a double


% --- Executes during object creation, after setting all properties.
function quaternion_i_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_i (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calculate_eulerAngles.
function calculate_eulerAngles_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_eulerAngles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get euler angles panel data ------------------------------
X_ang = str2double(get(handles.X_angle, 'String'));
Y_ang = str2double(get(handles.Y_angle, 'String'));
Z_ang = str2double(get(handles.Z_angle, 'String'));

%Calculate Rotation & quaternion --------------------
Rmat = RotwithEaaAngles(X_ang, Y_ang, Z_ang);
quat = rotm2quat(Rmat);
SetQuat(quat);


%Update other panels --------------------------------------
% Panel Rotation Matrix -----------------------------------
Rmat = check_zeros(Rmat);
set(handles.rotmat1_1, 'String', Rmat(1));
set(handles.rotmat1_2, 'String', Rmat(4));
set(handles.rotmat1_3, 'String', Rmat(7));
set(handles.rotmat2_1, 'String', Rmat(2));
set(handles.rotmat2_2, 'String', Rmat(5));
set(handles.rotmat2_3, 'String', Rmat(8));
set(handles.rotmat3_1, 'String', Rmat(3));
set(handles.rotmat3_2, 'String', Rmat(6));
set(handles.rotmat3_3, 'String', Rmat(9));

% Panel Euler principal Angle and Axis ---------------------
[e_axis,angle] = rotMat2Eaa(Rmat);
e_axis = check_zeros(e_axis);
angle = check_zeros(angle);
set(handles.e_axis_x, 'String', e_axis(1));
set(handles.e_axis_y, 'String', e_axis(2));
set(handles.e_axis_z, 'String', e_axis(3));
set(handles.e_axis_angle, 'String', angle);
set(handles.e_axis_slider, 'Value', angle);

% Panel Rotation Vector ------------------------------------
rot_vec = e_axis * angle;
rot_vec = check_zeros(rot_vec);
set(handles.rot_vec_x, 'String',rot_vec(1));
set(handles.rot_vec_y, 'String',rot_vec(2));
set(handles.rot_vec_z, 'String',rot_vec(3));

% Panel Quaternion -----------------------------------------
Quaternion = rotm2quat(Rmat);
Quaternion = check_zeros(Quaternion);
set(handles.quaternion_i, 'String', Quaternion(1));
set(handles.quaternion_X, 'String', Quaternion(2));
set(handles.quaternion_Y, 'String', Quaternion(3));
set(handles.quaternion_Z, 'String', Quaternion(4));


%Apply the rotation ---------------------------------------
handles.Cube = RedrawCube(Rmat,handles.Cube);


function X_angle_Callback(hObject, eventdata, handles)
% hObject    handle to X_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of X_angle as text
%        str2double(get(hObject,'String')) returns contents of X_angle as a double


% --- Executes during object creation, after setting all properties.
function X_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_angle_Callback(hObject, eventdata, handles)
% hObject    handle to Y_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y_angle as text
%        str2double(get(hObject,'String')) returns contents of Y_angle as a double


% --- Executes during object creation, after setting all properties.
function Y_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Z_angle_Callback(hObject, eventdata, handles)
% hObject    handle to Z_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Z_angle as text
%        str2double(get(hObject,'String')) returns contents of Z_angle as a double


% --- Executes during object creation, after setting all properties.
function Z_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calculate_rot_vec.
function calculate_rot_vec_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_rot_vec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get Rotation Vector panel data --------------------------
rot_vec(1) = str2double(get(handles.rot_vec_x, 'String'));
rot_vec(2) = str2double(get(handles.rot_vec_y, 'String'));
rot_vec(3) = str2double(get(handles.rot_vec_z, 'String'));
if norm(rot_vec) == 0
    
    angle = 0;
    vector = [0;0;0];
    
else
    
    angle = norm(rot_vec) * 180/pi;
    angle = check_zeros(angle);
    vector = rot_vec/norm(rot_vec);
    vector = check_zeros(vector);

end

%Calculate Rotation matrix & quaternion --------------------
Rmat = Eaa2rotMat(vector,angle);
quat = rotm2quat(Rmat);
SetQuat(quat);

%Update other panels --------------------------------------
% Panel Rotation Matrix -----------------------------------
Rmat = check_zeros(Rmat);
set(handles.rotmat1_1, 'String', Rmat(1));
set(handles.rotmat1_2, 'String', Rmat(4));
set(handles.rotmat1_3, 'String', Rmat(7));
set(handles.rotmat2_1, 'String', Rmat(2));
set(handles.rotmat2_2, 'String', Rmat(5));
set(handles.rotmat2_3, 'String', Rmat(8));
set(handles.rotmat3_1, 'String', Rmat(3));
set(handles.rotmat3_2, 'String', Rmat(6));
set(handles.rotmat3_3, 'String', Rmat(9));

%Panel Euler principal Angle and Axis ---------------------
set(handles.e_axis_x, 'String', vector(1));
set(handles.e_axis_y, 'String', vector(2));
set(handles.e_axis_z, 'String', vector(3));

if angle > 360
   
    angle = (angle/360) - floor(angle / 360);
    angle = angle * 360;
    
    if angle > 180
        
    angle = angle - 360;
    end
    
end

set(handles.e_axis_angle, 'String', angle);
set(handles.e_axis_slider, 'Value', angle);

%Panel Quaternion -----------------------------------------
Quaternion = rotm2quat(Rmat);
Quaternion = check_zeros(Quaternion);
set(handles.quaternion_i, 'String', Quaternion(1));
set(handles.quaternion_X, 'String', Quaternion(2));
set(handles.quaternion_Y, 'String', Quaternion(3));
set(handles.quaternion_Z, 'String', Quaternion(4));

%Euler Angles ---------------------------------------------
[phi, theta, psi] = rotM2eAngles(Rmat);
phi = check_zeros(phi);
theta = check_zeros(theta);
psi = check_zeros(psi);
set(handles.X_angle, 'String', phi);
set(handles.Y_angle, 'String', theta);
set(handles.Z_angle, 'String', psi);

%Apply the rotation ---------------------------------------
handles.Cube = RedrawCube(Rmat,handles.Cube);





function rot_vec_x_Callback(hObject, eventdata, handles)
% hObject    handle to rot_vec_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rot_vec_x as text
%        str2double(get(hObject,'String')) returns contents of rot_vec_x as a double


% --- Executes during object creation, after setting all properties.
function rot_vec_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rot_vec_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rot_vec_y_Callback(hObject, eventdata, handles)
% hObject    handle to rot_vec_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rot_vec_y as text
%        str2double(get(hObject,'String')) returns contents of rot_vec_y as a double


% --- Executes during object creation, after setting all properties.
function rot_vec_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rot_vec_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rot_vec_z_Callback(hObject, eventdata, handles)
% hObject    handle to rot_vec_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rot_vec_z as text
%        str2double(get(hObject,'String')) returns contents of rot_vec_z as a double


% --- Executes during object creation, after setting all properties.
function rot_vec_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rot_vec_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Reset_Button.
function Reset_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Initi Rotation matrix & quaternion --------------------
Rmat = [1,0,0;0,1,0;0,0,1];
quat = [1;0;0;0];
SetQuat(quat);

%Reset panels ---------------------------------------------
% Panel Rotation Matrix -----------------------------------
set(handles.rotmat1_1, 'String', Rmat(1));
set(handles.rotmat1_2, 'String', Rmat(4));
set(handles.rotmat1_3, 'String', Rmat(7));
set(handles.rotmat2_1, 'String', Rmat(2));
set(handles.rotmat2_2, 'String', Rmat(5));
set(handles.rotmat2_3, 'String', Rmat(8));
set(handles.rotmat3_1, 'String', Rmat(3));
set(handles.rotmat3_2, 'String', Rmat(6));
set(handles.rotmat3_3, 'String', Rmat(9));

% Panel Euler principal Angle and Axis --------------------
set(handles.e_axis_x, 'String', 0);
set(handles.e_axis_y, 'String', 0);
set(handles.e_axis_z, 'String', 0);
set(handles.e_axis_angle, 'String', 0);
set(handles.e_axis_slider, 'Value', 0);

% Panel Quaternion ----------------------------------------
set(handles.quaternion_i, 'String', quat(1));
set(handles.quaternion_X, 'String', quat(2));
set(handles.quaternion_Y, 'String', quat(3));
set(handles.quaternion_Z, 'String', quat(4));

% Panel Euler Angles --------------------------------------
set(handles.X_angle, 'String', 0);
set(handles.Y_angle, 'String', 0);
set(handles.Z_angle, 'String', 0);

% Panel Rotation Vector -----------------------------------
set(handles.rot_vec_x, 'String', 0);
set(handles.rot_vec_y, 'String', 0);
set(handles.rot_vec_z, 'String', 0);

%Apply the rotation ---------------------------------------
handles.Cube = RedrawCube(Rmat,handles.Cube);
